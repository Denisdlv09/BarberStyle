import 'package:cloud_firestore/cloud_firestore.dart';

/// 📌 Modelo de Reseña
class ReviewModel {
  final String id;
  final String userId;
  final String barberiaId;
  final double puntuacion;
  final String comentario;
  final DateTime fecha;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.barberiaId,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      userId: map['userId'] ?? '',
      barberiaId: map['barberiaId'] ?? '',
      puntuacion: (map['puntuacion'] ?? 0).toDouble(),
      comentario: map['comentario'] ?? '',
      fecha: _parseDate(map['fecha']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'barberiaId': barberiaId,
      'puntuacion': puntuacion,
      'comentario': comentario,
      // Firestore guarda fechas como Timestamps, no strings.
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  /// 🔹 Permite recibir Timestamp, String o DateTime sin explotar.
  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
