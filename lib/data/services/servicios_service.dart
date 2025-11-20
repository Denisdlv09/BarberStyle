import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barberstyle/data/models/servicio_model.dart';

class ServicioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ///  Obtener servicios de una barbería
  Stream<List<ServicioModel>> obtenerServicios(String barberiaId) {
    return _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('servicios')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ServicioModel.fromMap(doc.data(), doc.id)).toList());
  }

  ///  Agregar servicio y devolver ID
  Future<String> agregarServicio(String barberiaId, ServicioModel servicio) async {
    try {
      final ref = await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('servicios')
          .add({
        ...servicio.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return ref.id;
    } catch (e) {
      throw Exception("Error agregando servicio: $e");
    }
  }

  ///  Actualizar servicio existente
  Future<void> actualizarServicio(String barberiaId, ServicioModel servicio) async {
    try {
      await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('servicios')
          .doc(servicio.id)
          .update(servicio.toMap()); //  Guardará duracion: 30
    } catch (e) {
      throw Exception("Error actualizando servicio: $e");
    }
  }

  ///  Eliminar servicio
  Future<void> eliminarServicio(String barberiaId, String servicioId) async {
    try {
      await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('servicios')
          .doc(servicioId)
          .delete();
    } catch (e) {
      throw Exception("Error eliminando servicio: $e");
    }
  }
}
