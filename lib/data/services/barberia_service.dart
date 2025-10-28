// TODO Implement this library.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/barberia_model.dart';

class BarberiaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Añadir nueva barbería
  Future<void> agregarBarberia(BarberiaModel barberia) async {
    await _db.collection('barberias').doc(barberia.id).set(barberia.toMap());
  }

  // Obtener todas las barberías
  Stream<List<BarberiaModel>> obtenerBarberias() {
    return _db.collection('barberias').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BarberiaModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Obtener una barbería por ID
  Future<BarberiaModel?> obtenerBarberiaPorId(String id) async {
    DocumentSnapshot doc = await _db.collection('barberias').doc(id).get();
    if (doc.exists) {
      return BarberiaModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Actualizar barbería
  Future<void> actualizarBarberia(String id, Map<String, dynamic> data) async {
    await _db.collection('barberias').doc(id).update(data);
  }

  // Eliminar barbería
  Future<void> eliminarBarberia(String id) async {
    await _db.collection('barberias').doc(id).delete();
  }
}
