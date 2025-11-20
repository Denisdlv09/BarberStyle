///  Modelo de Servicio
class ServicioModel {
  final String id;
  final String nombre;
  final double precio;

  ///  Duración fija siempre a 30 min
  final int duracion = 30;

  ServicioModel({
    required this.id,
    required this.nombre,
    required this.precio,
  });

  factory ServicioModel.fromMap(Map<String, dynamic> map, String id) {
    return ServicioModel(
      id: id,
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'duracion': 30, // SIEMPRE 30
    };
  }
}
