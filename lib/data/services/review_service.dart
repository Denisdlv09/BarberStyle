import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> agregarReview(ReviewModel review) async {
    await _db.collection('reviews').doc(review.id).set(review.toMap());
  }

  Stream<List<ReviewModel>> obtenerReviewsPorBarberia(String barberiaId) {
    return _db.collection('reviews')
        .where('barberiaId', isEqualTo: barberiaId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data(), doc.id)).toList());
  }
}
