class ServicioModel {
  final String id;
  final String barberiaId;
  final String nombre;
  final double precio;
  final String duracion;
  final String descripcion;

  ServicioModel({
    required this.id,
    required this.barberiaId,
    required this.nombre,
    required this.precio,
    required this.duracion,
    required this.descripcion,
  });

  factory ServicioModel.fromMap(Map<String, dynamic> map, String id) {
    return ServicioModel(
      id: id,
      barberiaId: map['barberiaId'] ?? '',
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      duracion: map['duracion'] ?? '',
      descripcion: map['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barberiaId': barberiaId,
      'nombre': nombre,
      'precio': precio,
      'duracion': duracion,
      'descripcion': descripcion,
    };
  }
}
