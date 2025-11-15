import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/resena_model.dart';
import '../../data/services/resenas_service.dart';

class ResenasViewModel extends ChangeNotifier {
  final ReviewService _service = ReviewService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? errorMessage;

  ReviewModel? reviewActual;  // reseña del usuario si existe

  // -----------------------------------------------------------
  // Cargar reseña existente del usuario
  // -----------------------------------------------------------
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

  // -----------------------------------------------------------
  // Crear o actualizar reseña
  // -----------------------------------------------------------
  Future<void> guardarResena({
    required String barberiaId,
    required double puntuacion,
    required String comentario,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final nuevaResena = ReviewModel(
        id: reviewActual?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        barberiaId: barberiaId,
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

  // -----------------------------------------------------------
  // Eliminar reseña
  // -----------------------------------------------------------
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
