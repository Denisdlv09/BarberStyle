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
      fecha: DateTime.parse(map['fecha']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'barberiaId': barberiaId,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
    };
  }
}
