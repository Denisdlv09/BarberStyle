import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarberiaViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? barberiaData;
  List<Map<String, dynamic>> servicios = [];
  double ratingPromedio = 0;

  StreamSubscription<DocumentSnapshot>? _barberiaListener;
  StreamSubscription<QuerySnapshot>? _serviciosListener;

  /// 🔥 NUEVO: escucha cambios en tiempo real
  Future<void> cargarBarberia(String barberiaId) async {
    isLoading = true;
    notifyListeners();

    try {
      // ---------- LISTENER DE BARBERÍA ----------
      _barberiaListener = _db
          .collection('barberias')
          .doc(barberiaId)
          .snapshots()
          .listen((doc) {
        barberiaData = doc.data();
        ratingPromedio =
            (barberiaData?["ratingPromedio"] ?? 0).toDouble();

        notifyListeners(); // 🔥 se refresca INSTANTÁNEAMENTE
      });

      // ---------- LISTENER DE SERVICIOS ----------
      _serviciosListener = _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('servicios')
          .orderBy("nombre")
          .snapshots()
          .listen((snap) {
        servicios =
            snap.docs.map((d) => {...d.data(), "id": d.id}).toList();

        notifyListeners();
      });

    } catch (e) {
      errorMessage = "Error cargando barbería";
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _barberiaListener?.cancel();
    _serviciosListener?.cancel();
    super.dispose();
  }
}
