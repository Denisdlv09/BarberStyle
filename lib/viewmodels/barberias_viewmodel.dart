import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barberstyle/data/services/barberias_service.dart';

class BarberiasViewModel extends ChangeNotifier {
  final BarberiasService _service = BarberiasService();

  Map<String, dynamic>? barberiaData;
  String? barberiaId;

  bool isLoading = false;
  String? errorMessage;

  // -------------------------------------------------------
  // Cargar barbería del admin
  // -------------------------------------------------------

  Future<void> loadBarberiaByAdmin(String adminId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getBarberiaByAdmin(adminId);

      if (result != null) {
        barberiaData = result['data'];
        barberiaId = result['id'];
      } else {
        barberiaData = null;
        barberiaId = null;
      }
    } catch (e) {
      errorMessage = "Error al cargar barbería";
    }

    isLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------
  // Crear barbería
  // -------------------------------------------------------

  Future<String?> crearBarberia(Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();

    try {
      final id = await _service.crearBarberia(data);

      final adminId = data['propietarioId'];
      await loadBarberiaByAdmin(adminId);

      return id;
    } catch (e) {
      errorMessage = "Error creando barbería";
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // Editar barbería
  // -------------------------------------------------------

  Future<void> actualizarBarberia(String id, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.actualizarBarberia(id, data);

      final adminId = FirebaseAuth.instance.currentUser?.uid;

      if (adminId != null) {
        await loadBarberiaByAdmin(adminId);
      }
    } catch (e) {
      errorMessage = "Error actualizando barbería";
    }

    isLoading = false;
    notifyListeners();
  }
}
