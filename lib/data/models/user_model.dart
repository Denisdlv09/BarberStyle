///  Modelo de Usuario
class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String rol; // admin | cliente

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      rol: map['rol'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
    };
  }
}
