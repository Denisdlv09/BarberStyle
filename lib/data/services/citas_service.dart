import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cita_model.dart';

class CitaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ---------------------------------------------------------
  /// 🔹 Crear cita
  /// Genera ID si no viene, guarda en barbería + usuario
  /// ---------------------------------------------------------
  Future<void> crearCita(CitaModel cita) async {
    try {
      final barberiaRef = _db
          .collection('barberias')
          .doc(cita.barberiaId)
          .collection('citas');

      // 🔹 Generar ID si viene nulo
      final docRef = (cita.id != null)
          ? barberiaRef.doc(cita.id)
          : barberiaRef.doc();

      final newId = docRef.id;

      // 🔹 Crear cita con ID ya asignado
      final citaConId = cita.copyWith(id: newId);

      // 🔹 Guardar en barbería y en usuario
      await Future.wait([
        barberiaRef.doc(newId).set(citaConId.toMap()),
        _db
            .collection('usuarios')
            .doc(citaConId.clienteId)
            .collection('citas')
            .doc(newId)
            .set(citaConId.toMap()),
      ]);
    } catch (e) {
      throw Exception("Error creando cita: $e");
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Stream de citas del usuario
  /// ---------------------------------------------------------
  Stream<List<CitaModel>> obtenerCitasPorUsuario(String userId) {
    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('citas')
        .orderBy('fecha')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CitaModel.fromMap(doc.data(), doc.id)).toList());
  }

  /// ---------------------------------------------------------
  /// 🔹 Stream de citas de la barbería
  /// ---------------------------------------------------------
  Stream<List<CitaModel>> obtenerCitasPorBarberia(String barberiaId) {
    return _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('citas')
        .orderBy('fecha')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CitaModel.fromMap(doc.data(), doc.id)).toList());
  }

  /// ---------------------------------------------------------
  /// 🔹 Actualizar estado de la cita en ambas colecciones
  /// ---------------------------------------------------------
  Future<void> actualizarEstado({
    required String barberiaId,
    required String citaId,
    required String clienteId,
    required String nuevoEstado,
  }) async {
    try {
      final updateData = {'estado': nuevoEstado};

      await Future.wait([
        _db
            .collection('barberias')
            .doc(barberiaId)
            .collection('citas')
            .doc(citaId)
            .update(updateData),
        _db
            .collection('usuarios')
            .doc(clienteId)
            .collection('citas')
            .doc(citaId)
            .update(updateData),
      ]);
    } catch (e) {
      throw Exception("Error actualizando estado de cita: $e");
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Eliminar cita en ambas colecciones
  /// ---------------------------------------------------------
  Future<void> eliminarCita({
    required String barberiaId,
    required String citaId,
    required String clienteId,
  }) async {
    try {
      await Future.wait([
        _db
            .collection('barberias')
            .doc(barberiaId)
            .collection('citas')
            .doc(citaId)
            .delete(),
        _db
            .collection('usuarios')
            .doc(clienteId)
            .collection('citas')
            .doc(citaId)
            .delete(),
      ]);
    } catch (e) {
      throw Exception("Error eliminando cita: $e");
    }
  }

  /// ---------------------------------------------------------
  /// 🔹 Alias (compatibilidad)
  /// ---------------------------------------------------------
  Future<void> cancelarCita(CitaModel cita) async {
    await eliminarCita(
      barberiaId: cita.barberiaId,
      citaId: cita.id,
      clienteId: cita.clienteId,
    );
  }
}
