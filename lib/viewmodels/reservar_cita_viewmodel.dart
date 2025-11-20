import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservarCitaViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? servicioSeleccionado;

  String? barberoSeleccionadoId;
  String? barberoSeleccionadoNombre;

  DateTime? fechaSeleccionada;
  String? horaSeleccionada;

  bool cargandoHoras = false;
  bool guardando = false;

  List<String> horasOcupadas = [];
  List<String> horasDisponibles = [];

  final List<String> horasTotales = const [
    "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30",
    "15:00", "15:30", "16:00", "16:30",
    "17:00", "17:30", "18:00", "18:30",
    "19:00", "19:30", "20:00", "20:30",
  ];


  // Selección barbero
  void seleccionarBarbero(String id, String nombre) {
    barberoSeleccionadoId = id;
    barberoSeleccionadoNombre = nombre;

    fechaSeleccionada = null;
    horaSeleccionada = null;

    notifyListeners();
  }

  void seleccionarServicio(String? servicio) {
    servicioSeleccionado = servicio;
    notifyListeners();
  }

  // Selección de fecha

  Future<void> seleccionarFecha(DateTime fecha, String barberiaId) async {
    fechaSeleccionada = fecha;
    horaSeleccionada = null;

    if (barberoSeleccionadoId != null) {
      await cargarHorasOcupadas(barberiaId, barberoSeleccionadoId!);
    }

    notifyListeners();
  }

  // Horas ocupadas por BARBERO
  Future<void> cargarHorasOcupadas(
      String barberiaId, String barberoId) async {
    if (fechaSeleccionada == null) return;

    cargandoHoras = true;
    notifyListeners();

    try {
      final fechaStr =
      DateFormat('yyyy-MM-dd').format(fechaSeleccionada!);

      final snap = await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('barberos')
          .doc(barberoId)
          .collection('citas')
          .where('fechaStr', isEqualTo: fechaStr)
          .get();

      horasOcupadas =
          snap.docs.map((e) => e['hora'] as String).toList();

      horasDisponibles = horasTotales
          .where((h) => !horasOcupadas.contains(h))
          .toList();
    } catch (_) {
      horasDisponibles = horasTotales;
    }

    cargandoHoras = false;
    notifyListeners();
  }

  void seleccionarHora(String hora) {
    horaSeleccionada = hora;
    notifyListeners();
  }

  // Crear cita
  Future<String?> crearCita({
    required String barberiaId,
    required String barberiaNombre,
  }) async {
    if (servicioSeleccionado == null ||
        barberoSeleccionadoId == null ||
        fechaSeleccionada == null ||
        horaSeleccionada == null) {
      return "Completa todos los campos";
    }

    guardando = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) return "Usuario no autenticado";

      final userDoc = await _db
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final nombreCliente =
          userDoc.data()?["nombre"] ?? "Cliente";

      final fechaStr =
      DateFormat('yyyy-MM-dd').format(fechaSeleccionada!);

      final partes = horaSeleccionada!.split(":");
      final fechaFinal = DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada!.month,
        fechaSeleccionada!.day,
        int.parse(partes[0]),
        int.parse(partes[1]),
      );

      // validar disponibilidad
      final check = await _db
          .collection('barberias')
          .doc(barberiaId)
          .collection('barberos')
          .doc(barberoSeleccionadoId)
          .collection('citas')
          .where('fechaStr', isEqualTo: fechaStr)
          .where('hora', isEqualTo: horaSeleccionada)
          .get();

      if (check.docs.isNotEmpty) {
        guardando = false;
        notifyListeners();
        return "La hora ya está ocupada para este barbero";
      }

      final data = {
        'clienteId': user.uid,
        'clienteNombre': nombreCliente,
        'barberiaId': barberiaId,
        'barberiaNombre': barberiaNombre,

        'barberoId': barberoSeleccionadoId,
        'barberoNombre': barberoSeleccionadoNombre,

        'servicio': servicioSeleccionado,
        'fecha': Timestamp.fromDate(fechaFinal),
        'fechaStr': fechaStr,
        'hora': horaSeleccionada,
        'estado': 'pendiente',
        'createdAt': FieldValue.serverTimestamp(),
      };


      final citaRef = _db
          .collection("barberias")
          .doc(barberiaId)
          .collection("barberos")
          .doc(barberoSeleccionadoId)
          .collection("citas")
          .doc();

      //  Guardamos la cita SOLO en la ruta del BARBERO
      await citaRef.set(data);


      //  cita en usuario
      await _db
          .collection("usuarios")
          .doc(user.uid)
          .collection("citas")
          .doc(citaRef.id) // Usamos el ID de la cita guardada en el barbero
          .set(data);

      guardando = false;
      notifyListeners();
      return null;
    } catch (e) {
      guardando = false;
      notifyListeners();
      return "Error al guardar cita: $e";
    }
  }
}