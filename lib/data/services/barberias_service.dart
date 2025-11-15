import 'package:cloud_firestore/cloud_firestore.dart';

class BarberiasService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Obtener barbería por ID de propietario
  Future<Map<String, dynamic>?> getBarberiaByAdmin(String adminId) async {
    try {
      final query = await _db
          .collection('barberias')
          .where('propietarioId', isEqualTo: adminId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return {
        'id': doc.id,
        'data': doc.data(),
      };
    } catch (e) {
      throw Exception("Error obteniendo barbería: $e");
    }
  }

  /// 🔹 Crear barbería y devolver ID
  Future<String> crearBarberia(Map<String, dynamic> data) async {
    try {
      final doc = await _db.collection("barberias").add(data);
      return doc.id;
    } catch (e) {
      throw Exception("Error creando barbería: $e");
    }
  }

  /// 🔹 Actualizar barbería
  Future<void> actualizarBarberia(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection("barberias").doc(id).update(data);
    } catch (e) {
      throw Exception("Error actualizando barbería: $e");
    }
  }
}
