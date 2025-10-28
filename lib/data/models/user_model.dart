class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final bool esBarbero; // Para diferenciar usuario/barbería
  final List<String> favoritos;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.esBarbero,
    required this.favoritos,
  });

  // Convertir datos de Firebase a objeto Dart
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      esBarbero: map['esBarbero'] ?? false,
      favoritos: List<String>.from(map['favoritos'] ?? []),
    );
  }

  // Convertir objeto Dart a mapa para Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'esBarbero': esBarbero,
      'favoritos': favoritos,
    };
  }
}
