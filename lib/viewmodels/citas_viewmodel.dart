import 'package:flutter/material.dart';
import 'package:barberstyle/data/models/cita_model.dart';
import 'package:barberstyle/data/services/citas_service.dart';

class CitasViewModel extends ChangeNotifier {
  final CitaService _citaService = CitaService();

  bool isLoading = false;
  String? error;


  // STREAMS

  Stream<List<CitaModel>> getCitasPorUsuario(String userId) {
    return _citaService.obtenerCitasPorUsuario(userId);
  }

  Stream<List<CitaModel>> getCitasPorBarberia(String barberiaId) {
    return _citaService.obtenerCitasPorBarberia(barberiaId);
  }


  // CREAR CITA

  Future<void> crearCita(Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();

      final cita = CitaModel.fromMap(data, null);
      await _citaService.crearCita(cita);

    } catch (e) {
      error = "Error creando cita: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // ACCIONES SOBRE CITAS

  /// Cliente cancela su cita (equivalente a eliminarla)
  Future<void> cancelarCita(CitaModel cita) async {
    try {
      await _citaService.eliminarCita(
        barberiaId: cita.barberiaId,
        citaId: cita.id,
        clienteId: cita.clienteId,
        barberoId: cita.barberoId.isNotEmpty ? cita.barberoId : null,
      );
    } catch (e) {
      error = "Error cancelando cita: $e";
      notifyListeners();
    }
  }

  /// ADMIN elimina cita
  Future<void> eliminarCita({
    required String barberiaId,
    required String citaId,
    required String clienteId,
    required String? barberoId,
  }) async {
    try {
      await _citaService.eliminarCita(
        barberiaId: barberiaId,
        citaId: citaId,
        clienteId: clienteId,
        barberoId: barberoId,
      );
    } catch (e) {
      error = "Error eliminando cita: $e";
      notifyListeners();
    }
  }

  /// ADMIN marca cita como completada
  Future<void> actualizarEstado({
    required String barberiaId,
    required String citaId,
    required String clienteId,
    required String nuevoEstado,
    required String? barberoId,
  }) async {
    try {
      await _citaService.actualizarEstado(
        barberiaId: barberiaId,
        citaId: citaId,
        clienteId: clienteId,
        nuevoEstado: nuevoEstado,
        barberoId: barberoId,
      );
    } catch (e) {
      error = "Error actualizando estado: $e";
      notifyListeners();
    }
  }
}
