import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barberstyle/data/services/barberias_service.dart';

class BarberiasViewModel extends ChangeNotifier {
  final BarberiasService _service = BarberiasService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic>? barberiaData;
  String? barberiaId;

  bool isLoading = false;
  String? errorMessage;

  BarberiasViewModel();

  // -------------------------------------------------------
  // Cargar barbería del admin (igual que antes)
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // Crear barbería (devuelve id)
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
  // Actualizar barbería (sin tocar barberos)
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // 🔥 CRUD BARBEROS (directo con Firestore)
  // ============================
  /// Agregar barbero (crea doc en /barberias/{barberiaId}/barberos)
  Future<String?> agregarBarbero(String barberiaId, String nombre) async {
    try {
      final ref = await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('barberos')
          .add({
        'nombre': nombre,
        'createdAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
      return ref.id;
    } catch (e) {
      errorMessage = "Error agregando barbero";
      notifyListeners();
      return null;
    }
  }

  /// Editar barbero
  Future<bool> editarBarbero(String barberiaId, String barberoId, String nombre) async {
    try {
      await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('barberos')
          .doc(barberoId)
          .update({
        'nombre': nombre,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Error editando barbero";
      notifyListeners();
      return false;
    }
  }

  /// Eliminar barbero (no elimina sus citas; si quieres eso también, lo añadimos)
  Future<bool> eliminarBarbero(String barberiaId, String barberoId) async {
    try {
      await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('barberos')
          .doc(barberoId)
          .delete();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Error eliminando barbero";
      notifyListeners();
      return false;
    }
  }
}
