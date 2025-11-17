import 'package:cloud_firestore/cloud_firestore.dart';

/// 📌 Modelo de Cita
class CitaModel {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String barberiaId;
  final String barberiaNombre;
  final String barberoId;       // puede estar vacío
  final String barberoNombre;   // puede estar vacío
  final DateTime fecha;
  final String servicio;
  final String estado;
  final bool confirmada;

  CitaModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.barberiaId,
    required this.barberiaNombre,
    required this.barberoId,
    required this.barberoNombre,
    required this.fecha,
    required this.servicio,
    required this.estado,
    required this.confirmada,
  });

  /// ✔ Permite id nulo
  factory CitaModel.fromMap(Map<String, dynamic> map, String? id) {
    return CitaModel(
      id: id ?? '',
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? 'Cliente',
      barberiaId: map['barberiaId'] ?? '',
      barberiaNombre: map['barberiaNombre'] ?? '',
      barberoId: map['barberoId'] ?? '',
      barberoNombre: map['barberoNombre'] ?? '',
      fecha: _parseDate(map['fecha']),
      servicio: map['servicio'] ?? '',
      estado: map['estado'] ?? 'pendiente',
      confirmada: map['confirmada'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'barberiaId': barberiaId,
      'barberiaNombre': barberiaNombre,
      'barberoId': barberoId,
      'barberoNombre': barberoNombre,
      'fecha': Timestamp.fromDate(fecha),
      'servicio': servicio,
      'estado': estado,
      'confirmada': confirmada,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// ✔ copyWith completo y necesario
  CitaModel copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    String? barberiaId,
    String? barberiaNombre,
    String? barberoId,
    String? barberoNombre,
    DateTime? fecha,
    String? servicio,
    String? estado,
    bool? confirmada,
  }) {
    return CitaModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      barberiaId: barberiaId ?? this.barberiaId,
      barberiaNombre: barberiaNombre ?? this.barberiaNombre,
      barberoId: barberoId ?? this.barberoId,
      barberoNombre: barberoNombre ?? this.barberoNombre,
      fecha: fecha ?? this.fecha,
      servicio: servicio ?? this.servicio,
      estado: estado ?? this.estado,
      confirmada: confirmada ?? this.confirmada,
    );
  }
}
