import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/resena_model.dart';
import '../../data/services/resenas_service.dart';

class ResenasViewModel extends ChangeNotifier {
  final ReviewService _service = ReviewService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  ReviewModel? reviewActual;

  ///  Stream de TODAS las reseñas del usuario
  Stream<List<ReviewModel>> getResenasDelUsuario() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _service.obtenerResenasDelUsuario(user.uid);
  }

  ///  Cargar reseña existente de este usuario en esta barbería
  Future<void> cargarResena(String barberiaId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      reviewActual = await _service.obtenerReviewUsuario(barberiaId, user.uid);
    } catch (e) {
      errorMessage = "Error al cargar reseña";
    }

    isLoading = false;
    notifyListeners();
  }

  ///  Guardar o actualizar reseña
  Future<void> guardarResena({
    required String barberiaId,
    required String barberiaNombre,
    required double puntuacion,
    required String comentario,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Obtener nombre real del usuario
      final userDoc =
      await _db.collection("usuarios").doc(user.uid).get();

      final nombreReal = userDoc.data()?["nombre"] ?? "Cliente";

      final nuevaResena = ReviewModel(
        id: reviewActual?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        barberiaId: barberiaId,
        barberiaNombre: barberiaNombre,
        nombreCliente: nombreReal,
        puntuacion: puntuacion,
        comentario: comentario,
        fecha: DateTime.now(),
      );

      await _service.guardarReview(nuevaResena);
      await _service.actualizarPromedio(barberiaId);

      reviewActual = nuevaResena;
    } catch (e) {
      errorMessage = "Error al guardar reseña";
    }

    isLoading = false;
    notifyListeners();
  }

  ///  Eliminar reseña
  Future<void> eliminarResena(String barberiaId) async {
    if (reviewActual == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _service.eliminarReview(barberiaId, reviewActual!.id);
      await _service.actualizarPromedio(barberiaId);

      reviewActual = null;
    } catch (e) {
      errorMessage = "Error al eliminar reseña";
    }

    isLoading = false;
    notifyListeners();
  }
}
