import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarberiaViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? barberiaData;
  List<Map<String, dynamic>> servicios = [];
  double ratingPromedio = 0;

  Future<void> cargarBarberia(String barberiaId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Barbería
      final doc = await _db.collection('barberias').doc(barberiaId).get();
      barberiaData = doc.data() ?? {};

      // Servicios
      final serviciosSnap = await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('servicios')
          .orderBy("nombre")
          .get();

      servicios =
          serviciosSnap.docs.map((d) => {...d.data(), "id": d.id}).toList();

      ratingPromedio = (barberiaData?['ratingPromedio'] ?? 0).toDouble();
    } catch (e) {
      errorMessage = "Error cargando barbería";
    }

    isLoading = false;
    notifyListeners();
  }
}
