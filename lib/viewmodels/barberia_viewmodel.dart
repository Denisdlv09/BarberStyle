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

  ///  Lista de barberos
  List<Map<String, dynamic>> barberos = [];

  ///  Barbero seleccionado
  String? barberoSeleccionadoId;
  String? barberoSeleccionadoNombre;

  StreamSubscription<DocumentSnapshot>? _barberiaListener;
  StreamSubscription<QuerySnapshot>? _serviciosListener;

  ///  Listener barberos
  StreamSubscription<QuerySnapshot>? _barberosListener;


  // Cargar todo de la barbería

  Future<void> cargarBarberia(String barberiaId) async {
    isLoading = true;
    notifyListeners();

    try {
      //  BARBERÍA
      _barberiaListener = _db
          .collection('barberias')
          .doc(barberiaId)
          .snapshots()
          .listen((doc) {
        barberiaData = doc.data();
        ratingPromedio =
            (barberiaData?["ratingPromedio"] ?? 0).toDouble();

        notifyListeners();
      });

      //  SERVICIOS
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

      //  BARBEROS
      _barberosListener = _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('barberos')
          .orderBy("nombre")
          .snapshots()
          .listen((snap) {
        barberos =
            snap.docs.map((d) => {...d.data(), "id": d.id}).toList();

        notifyListeners();
      });

    } catch (e) {
      errorMessage = "Error cargando barbería";
    }

    isLoading = false;
    notifyListeners();
  }


  //  Seleccionar barbero
  void seleccionarBarbero(String id, String nombre) {
    barberoSeleccionadoId = id;
    barberoSeleccionadoNombre = nombre;

    notifyListeners();
  }


  //  Reset barbero
  void limpiarBarbero() {
    barberoSeleccionadoId = null;
    barberoSeleccionadoNombre = null;

    notifyListeners();
  }


  @override
  void dispose() {
    _barberiaListener?.cancel();
    _serviciosListener?.cancel();
    _barberosListener?.cancel();
    super.dispose();
  }
}
