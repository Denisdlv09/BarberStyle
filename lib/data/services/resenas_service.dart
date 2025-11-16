import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resena_model.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ReviewModel>> obtenerReviewsPorBarberia(String barberiaId) {
    return _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('resenas')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((d) => ReviewModel.fromMap(d.data(), d.id)).toList());
  }

  Future<ReviewModel?> obtenerReviewUsuario(
      String barberiaId, String userId) async {
    final snap = await _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('resenas')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    return ReviewModel.fromMap(doc.data(), doc.id);
  }

  Future<void> guardarReview(ReviewModel review) async {
    await _db
        .collection('barberias')
        .doc(review.barberiaId)
        .collection('resenas')
        .doc(review.id)
        .set(review.toMap(), SetOptions(merge: true));
  }

  Future<void> eliminarReview(String barberiaId, String reviewId) async {
    await _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('resenas')
        .doc(reviewId)
        .delete();
  }

  Future<double> calcularPromedio(String barberiaId) async {
    final snap = await _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('resenas')
        .get();

    if (snap.docs.isEmpty) return 0;

    double total = 0;
    for (final doc in snap.docs) {
      total += (doc['puntuacion'] ?? 0).toDouble();
    }

    return total / snap.docs.length;
  }

  Future<void> actualizarPromedio(String barberiaId) async {
    final promedio = await calcularPromedio(barberiaId);

    await _db.collection('barberias').doc(barberiaId).update({
      'ratingPromedio': promedio,
    });
  }
}
