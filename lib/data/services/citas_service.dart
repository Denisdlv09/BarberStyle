import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/cita_model.dart';

class CitaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Crear cita
  // ---------------------------------------------------------
  Future<void> crearCita(CitaModel cita) async {
    try {
      if (cita.barberoId.isNotEmpty) {
        // Ruta nueva: barberias/{id}/barberos/{id}/citas/{id}
        final ref = _db
            .collection('barberias')
            .doc(cita.barberiaId)
            .collection('barberos')
            .doc(cita.barberoId)
            .collection('citas');

        final docRef = ref.doc();
        final newId = docRef.id;
        final citaConId = cita.copyWith(id: newId);

        final batch = _db.batch();

        batch.set(docRef, citaConId.toMap());

        // Copia en usuarios
        batch.set(
          _db
              .collection('usuarios')
              .doc(citaConId.clienteId)
              .collection('citas')
              .doc(newId),
          citaConId.toMap(),
        );

        await batch.commit();
      } else {
        // Ruta antigua
        final ref = _db
            .collection('barberias')
            .doc(cita.barberiaId)
            .collection('citas');

        final docRef = ref.doc();
        final newId = docRef.id;
        final citaConId = cita.copyWith(id: newId);

        await Future.wait([
          ref.doc(newId).set(citaConId.toMap()),
          _db
              .collection('usuarios')
              .doc(citaConId.clienteId)
              .collection('citas')
              .doc(newId)
              .set(citaConId.toMap()),
        ]);
      }
    } catch (e) {
      throw Exception("Error creando cita: $e");
    }
  }

  // ---------------------------------------------------------
  // Obtener citas del usuario
  // ---------------------------------------------------------
  Stream<List<CitaModel>> obtenerCitasPorUsuario(String userId) {
    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('citas')
        .orderBy('fecha')
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => CitaModel.fromMap(d.data(), d.id))
        .toList());
  }

  // ---------------------------------------------------------
  // 🔥 Obtener citas de TODA la barbería SIN ÍNDICES
  // ---------------------------------------------------------
  Stream<List<CitaModel>> obtenerCitasPorBarberia(String barberiaId) async* {
    final barberiaRef = _db.collection('barberias').doc(barberiaId);

    // 1. obtener barberos
    final barberosSnap = await barberiaRef.collection('barberos').get();
    final barberoIds = barberosSnap.docs.map((d) => d.id).toList();

    // Streams de cada barbero
    final streams = <Stream<List<CitaModel>>>[];

    for (final barberoId in barberoIds) {
      final s = barberiaRef
          .collection('barberos')
          .doc(barberoId)
          .collection('citas')
          .snapshots()
          .map((snap) => snap.docs
          .map((d) => CitaModel.fromMap(d.data(), d.id))
          .toList());
      streams.add(s);
    }

    // agregar colección vieja
    final oldStream = barberiaRef
        .collection('citas')
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => CitaModel.fromMap(d.data(), d.id))
        .toList());

    streams.add(oldStream);

    // Unir todos los streams
    yield* CombineLatestStream.list<List<CitaModel>>(streams).map((listas) {
      final todas = <CitaModel>[];
      for (final l in listas) {
        todas.addAll(l);
      }

      // ordenar por fecha
      todas.sort((a, b) => a.fecha.compareTo(b.fecha));

      return todas;
    });
  }

  // ---------------------------------------------------------
  // Actualizar estado
  // ---------------------------------------------------------
  Future<void> actualizarEstado({
    required String barberiaId,
    required String citaId,
    required String clienteId,
    required String nuevoEstado,
    String? barberoId,
  }) async {
    try {
      final data = {'estado': nuevoEstado};

      final ops = <Future>[];

      if (barberoId != null && barberoId.isNotEmpty) {
        ops.add(_db
            .collection('barberias')
            .doc(barberiaId)
            .collection('barberos')
            .doc(barberoId)
            .collection('citas')
            .doc(citaId)
            .update(data));
      } else {
        ops.add(_db
            .collection('barberias')
            .doc(barberiaId)
            .collection('citas')
            .doc(citaId)
            .update(data)
            .catchError((_) {}));
      }

      ops.add(_db
          .collection('usuarios')
          .doc(clienteId)
          .collection('citas')
          .doc(citaId)
          .update(data));

      await Future.wait(ops);
    } catch (e) {
      throw Exception("Error actualizando estado: $e");
    }
  }

  // ---------------------------------------------------------
  // Eliminar cita
  // ---------------------------------------------------------
  Future<void> eliminarCita({
    required String barberiaId,
    required String citaId,
    required String clienteId,
    String? barberoId,
  }) async {
    try {
      final ops = <Future>[];

      if (barberoId != null && barberoId.isNotEmpty) {
        ops.add(_db
            .collection('barberias')
            .doc(barberiaId)
            .collection('barberos')
            .doc(barberoId)
            .collection('citas')
            .doc(citaId)
            .delete());
      } else {
        ops.add(_db
            .collection('barberias')
            .doc(barberiaId)
            .collection('citas')
            .doc(citaId)
            .delete()
            .catchError((_) {}));
      }

      ops.add(_db
          .collection('usuarios')
          .doc(clienteId)
          .collection('citas')
          .doc(citaId)
          .delete());

      await Future.wait(ops);
    } catch (e) {
      throw Exception("Error eliminando cita: $e");
    }
  }
}
