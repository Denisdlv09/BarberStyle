import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barberstyle/data/models/servicio_model.dart';

class ServicioService {
  final CollectionReference _serviciosRef =
  FirebaseFirestore.instance.collection('servicios');

  Stream<List<ServicioModel>> obtenerServiciosPorBarberia(String barberiaId) {
    return _serviciosRef
        .where('barberiaId', isEqualTo: barberiaId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ServicioModel.fromMap(
        doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> agregarServicio(ServicioModel servicio) async {
    await _serviciosRef.add(servicio.toMap());
  }
}
