import 'package:flutter/material.dart';
import 'package:barberstyle/data/services/servicios_service.dart';
import 'package:barberstyle/data/models/servicio_model.dart';

class ServiciosViewModel extends ChangeNotifier {
  final ServicioService _service = ServicioService();

  bool isLoading = false;
  String? errorMessage;

  // -------------------------------------------------------
  // Obtener servicios como Stream
  // -------------------------------------------------------

  Stream<List<ServicioModel>> getServicios(String barberiaId) {
    return _service.obtenerServicios(barberiaId);
  }

  // -------------------------------------------------------
  // Agregar servicio (duración fija = 30)
  // -------------------------------------------------------

  Future<void> agregarServicio(
      String barberiaId,
      String nombre,
      double precio,
      ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final servicio = ServicioModel(
        id: '',
        nombre: nombre,
        precio: precio,
      );

      await _service.agregarServicio(barberiaId, servicio);

    } catch (e) {
      errorMessage = "Error al agregar servicio";
    }

    isLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------
  // Editar servicio (duración fija = 30)
  // -------------------------------------------------------

  Future<void> editarServicio(
      String barberiaId,
      String servicioId,
      String nombre,
      double precio,
      ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final servicio = ServicioModel(
        id: servicioId,
        nombre: nombre,
        precio: precio,
      );

      await _service.actualizarServicio(barberiaId, servicio);

    } catch (e) {
      errorMessage = "Error al actualizar servicio";
    }

    isLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------
  // Eliminar servicio
  // -------------------------------------------------------

  Future<void> eliminarServicio(String barberiaId, String servicioId) async {
    try {
      await _service.eliminarServicio(barberiaId, servicioId);
    } catch (e) {
      errorMessage = "Error al eliminar servicio";
      notifyListeners();
    }
  }
}
