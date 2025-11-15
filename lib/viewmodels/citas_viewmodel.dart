import 'package:flutter/material.dart';
import 'package:barberstyle/data/models/cita_model.dart';
import 'package:barberstyle/data/services/citas_service.dart';

class CitasViewModel extends ChangeNotifier {
  final CitaService _citaService = CitaService();

  bool isLoading = false;
  String? error;

  // -------------------------------------------------------
  // Streams de citas
  // -------------------------------------------------------

  Stream<List<CitaModel>> getCitasPorUsuario(String userId) {
    return _citaService.obtenerCitasPorUsuario(userId);
  }

  Stream<List<CitaModel>> getCitasPorBarberia(String barberiaId) {
    return _citaService.obtenerCitasPorBarberia(barberiaId);
  }

  // -------------------------------------------------------
  // Crear cita
  // -------------------------------------------------------

  Future<void> crearCita(Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();

      final cita = CitaModel.fromMap(data, null); // id lo genera el service

      await _citaService.crearCita(cita);
    } catch (e) {
      error = "Error creando cita: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // Acciones sobre citas
  // -------------------------------------------------------

  Future<void> cancelarCita(CitaModel cita) async {
    await _citaService.cancelarCita(cita);
  }

  Future<void> eliminarCita({
    required String barberiaId,
    required String citaId,
    required String clienteId,
  }) async {
    await _citaService.eliminarCita(
      barberiaId: barberiaId,
      citaId: citaId,
      clienteId: clienteId,
    );
  }

  Future<void> actualizarEstado({
    required String barberiaId,
    required String citaId,
    required String clienteId,
    required String nuevoEstado,
  }) async {
    await _citaService.actualizarEstado(
      barberiaId: barberiaId,
      citaId: citaId,
      clienteId: clienteId,
      nuevoEstado: nuevoEstado,
    );
  }
}
