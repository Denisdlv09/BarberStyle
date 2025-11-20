import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barberstyle/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  ///  Registrar usuario
  Future<UserModel> register({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String rol,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: cred.user!.uid,
        nombre: nombre,
        email: email,
        telefono: telefono,
        rol: rol,
      );

      await _db.collection("usuarios").doc(user.id).set(user.toMap());
      return user;
    } catch (e) {
      throw Exception("Error registrando usuario: $e");
    }
  }


  ///  Login
  Future<UserModel> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _db.collection("usuarios").doc(cred.user!.uid).get();

      if (!doc.exists) {
        throw Exception("El usuario no existe en Firestore.");
      }

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception("Error iniciando sesión: $e");
    }
  }


  ///  Obtener usuario actual desde Firestore
  ///     (Método que usa AuthViewModel)
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection("usuarios").doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, doc.id);
  }


  ///  Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
