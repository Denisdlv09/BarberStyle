///  Modelo de Barbero
import 'package:cloud_firestore/cloud_firestore.dart';

class BarberoModel {
  final String? id;
  final String nombre;
  final bool activo;
  final DateTime? createdAt;

  BarberoModel({
    this.id,
    required this.nombre,
    this.activo = true,
    this.createdAt,
  });

  factory BarberoModel.fromMap(Map<String, dynamic> map, String id) {
    return BarberoModel(
      id: id,
      nombre: map['nombre'] ?? '',
      activo: map['activo'] ?? true,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'activo': activo,
      // createdAt se gestiona en Firestore (serverTimestamp)
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  BarberoModel copyWith({
    String? id,
    String? nombre,
    bool? activo,
    DateTime? createdAt,
  }) {
    return BarberoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
