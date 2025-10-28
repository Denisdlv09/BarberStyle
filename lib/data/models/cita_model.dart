class CitaModel {
  final String id;
  final String userId;
  final String barberiaId;
  final DateTime fecha;
  final String servicio;
  final bool confirmada;

  CitaModel({
    required this.id,
    required this.userId,
    required this.barberiaId,
    required this.fecha,
    required this.servicio,
    required this.confirmada,
  });

  factory CitaModel.fromMap(Map<String, dynamic> map, String id) {
    return CitaModel(
      id: id,
      userId: map['userId'] ?? '',
      barberiaId: map['barberiaId'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      servicio: map['servicio'] ?? '',
      confirmada: map['confirmada'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'barberiaId': barberiaId,
      'fecha': fecha.toIso8601String(),
      'servicio': servicio,
      'confirmada': confirmada,
    };
  }
}
