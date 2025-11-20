import 'package:cloud_firestore/cloud_firestore.dart';

///  Modelo de Reseña
class ReviewModel {
  final String id;
  final String userId;
  final String barberiaId;
  final String barberiaNombre;
  final String nombreCliente;
  final double puntuacion;
  final String comentario;
  final DateTime fecha;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.barberiaId,
    required this.barberiaNombre,
    required this.nombreCliente,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      userId: map['userId'] ?? '',
      barberiaId: map['barberiaId'] ?? '',
      barberiaNombre: map['barberiaNombre'] ?? '',
      nombreCliente: map['nombreCliente'] ?? 'Cliente',
      puntuacion: (map['puntuacion'] ?? 0).toDouble(),
      comentario: map['comentario'] ?? '',
      fecha: _parseDate(map['fecha']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'barberiaId': barberiaId,
      'barberiaNombre': barberiaNombre,
      'nombreCliente': nombreCliente,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  ///  Maneja Timestamp, String y DateTime
  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
