import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cita_model.dart';

class CitaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> crearCita(CitaModel cita) async {
    await _db.collection('citas').doc(cita.id).set(cita.toMap());
  }

  Stream<List<CitaModel>> obtenerCitasPorUsuario(String userId) {
    return _db.collection('citas')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CitaModel.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<CitaModel>> obtenerCitasPorBarberia(String barberiaId) {
    return _db.collection('citas')
        .where('barberiaId', isEqualTo: barberiaId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CitaModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> cancelarCita(String id) async {
    await _db.collection('citas').doc(id).delete();
  }
}
