import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barberstyle/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar usuario guardando rol en Firestore
  Future<UserModel?> register({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String rol, // 'admin' o 'cliente'
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: cred.user!.uid,
        nombre: nombre,
        email: email,
        telefono: telefono,
        rol: rol,
      );

      await _db.collection('usuarios').doc(userModel.id).set(userModel.toMap());
      return userModel;
    } catch (e) {
      print('AuthService.register error: $e');
      return null;
    }
  }

  // Login y devuelve el modelo de usuario (datos desde Firestore)
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final doc = await _db.collection('usuarios').doc(cred.user!.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('AuthService.signIn error: $e');
      return null;
    }
  }

  Future<UserModel?> currentUserModel() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('usuarios').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
