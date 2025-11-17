import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/barbero_model.dart';

class BarberosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtener barberos de una barbería
  Stream<List<BarberoModel>> obtenerBarberos(String barberiaId) {
    return _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('barberos')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => BarberoModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  /// Agregar barbero
  Future<String> agregarBarbero(String barberiaId, BarberoModel barbero) async {
    final doc = await _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('barberos')
        .add(barbero.toMap());

    // añadir id real
    await doc.update({'id': doc.id});

    return doc.id;
  }

  /// Actualizar barbero
  Future<void> actualizarBarbero(String barberiaId, BarberoModel barbero) async {
    await _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('barberos')
        .doc(barbero.id)
        .update(barbero.toMap());
  }

  /// Eliminar barbero y opcionalmente TODAS sus citas
  Future<void> eliminarBarbero(
      String barberiaId,
      String barberoId, {
        bool borrarCitas = true,
      }) async {

    final barberoRef = _db
        .collection('barberias')
        .doc(barberiaId)
        .collection('barberos')
        .doc(barberoId);

    if (borrarCitas) {
      final citasSnap = await barberoRef.collection('citas').get();
      for (var doc in citasSnap.docs) {
        await doc.reference.delete();
      }
    }

    await barberoRef.delete();
  }
}
