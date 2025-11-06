import 'package:cloud_firestore/cloud_firestore.dart';

class CitaModel {
  final String id;
  final String clienteId;
  final String barberiaId;
  final String barberiaNombre;
  final DateTime fecha;
  final String servicio;
  final bool confirmada;

  CitaModel({
    required this.id,
    required this.clienteId,
    required this.barberiaId,
    required this.barberiaNombre,
    required this.fecha,
    required this.servicio,
    required this.confirmada,
  });

  factory CitaModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime fecha;

    if (map['fecha'] is Timestamp) {
      fecha = (map['fecha'] as Timestamp).toDate();
    } else if (map['fecha'] is String) {
      fecha = DateTime.parse(map['fecha']);
    } else {
      fecha = DateTime.now();
    }

    return CitaModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      barberiaId: map['barberiaId'] ?? '',
      barberiaNombre: map['barberiaNombre'] ?? '',
      fecha: fecha,
      servicio: map['servicio'] ?? '',
      confirmada: map['confirmada'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'barberiaId': barberiaId,
      'barberiaNombre': barberiaNombre,
      'fecha': Timestamp.fromDate(fecha),
      'servicio': servicio,
      'confirmada': confirmada,
    };
  }
}
