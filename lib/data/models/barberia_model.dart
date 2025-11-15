import 'package:cloud_firestore/cloud_firestore.dart';

/// 📌 Modelo de Barbería
class BarberiaModel {
  final String id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String descripcion;
  final String propietarioId;
  final String imagenLogo;
  final DateTime createdAt;

  BarberiaModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.descripcion,
    required this.propietarioId,
    required this.imagenLogo,
    required this.createdAt,
  });

  factory BarberiaModel.fromMap(Map<String, dynamic> map, String id) {
    return BarberiaModel(
      id: id,
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      descripcion: map['descripcion'] ?? '',
      propietarioId: map['propietarioId'] ?? '',
      imagenLogo: map['imagenLogo'] ?? '',
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'descripcion': descripcion,
      'propietarioId': propietarioId,
      'imagenLogo': imagenLogo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Manejo seguro de fecha Firestore / String / DateTime
  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
