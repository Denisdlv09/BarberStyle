class BarberiaModel {
  final String id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String descripcion;
  final String imagenUrl;
  final double valoracion;
  final List<String> servicios;

  BarberiaModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.descripcion,
    required this.imagenUrl,
    required this.valoracion,
    required this.servicios,
  });

  factory BarberiaModel.fromMap(Map<String, dynamic> map, String id) {
    return BarberiaModel(
      id: id,
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      descripcion: map['descripcion'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      valoracion: (map['valoracion'] ?? 0).toDouble(),
      servicios: List<String>.from(map['servicios'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'valoracion': valoracion,
      'servicios': servicios,
    };
  }
}
