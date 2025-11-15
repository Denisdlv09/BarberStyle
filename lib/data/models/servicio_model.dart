/// 📌 Modelo de Servicio
class ServicioModel {
  final String id;
  final String nombre;
  final double precio;
  final int duracion;

  ServicioModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.duracion,
  });

  factory ServicioModel.fromMap(Map<String, dynamic> map, String id) {
    return ServicioModel(
      id: id,
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      duracion: map['duracion'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'duracion': duracion,
    };
  }
}
