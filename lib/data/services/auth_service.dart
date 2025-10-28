import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar nuevo usuario
  Future<UserModel?> registrarUsuario({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    bool esBarbero = false,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel nuevoUsuario = UserModel(
        id: cred.user!.uid,
        nombre: nombre,
        email: email,
        telefono: telefono,
        esBarbero: esBarbero,
        favoritos: [],
      );

      await _db.collection('usuarios').doc(nuevoUsuario.id).set(nuevoUsuario.toMap());

      return nuevoUsuario;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return null;
    }
  }

  // Iniciar sesión
  Future<UserModel?> iniciarSesion(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot doc = await _db.collection('usuarios').doc(cred.user!.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  Future<UserModel?> obtenerUsuarioActual() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc = await _db.collection('usuarios').doc(user.uid).get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
