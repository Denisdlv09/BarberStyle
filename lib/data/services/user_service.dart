import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  ///  Obtener datos completos del usuario actual
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.collection('usuarios').doc(user.uid).get();

      return doc.data();
    } catch (e) {
      throw Exception("Error obteniendo datos del usuario: $e");
    }
  }

  ///  Actualizar datos del usuario
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('usuarios').doc(user.uid).update(data);
    } catch (e) {
      throw Exception("Error actualizando datos del usuario: $e");
    }
  }

  ///  Eliminar cuenta y todas sus citas
  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userRef = _db.collection('usuarios').doc(user.uid);

      // Eliminar citas del usuario
      final citas = await userRef.collection('citas').get();
      for (final doc in citas.docs) {
        await doc.reference.delete();
      }

      // Eliminar documento del usuario
      await userRef.delete();

      // Eliminar usuario de Auth
      await user.delete();
    } catch (e) {
      throw Exception("Error eliminando cuenta de usuario: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  ///  Stream en tiempo real de barberías
  Stream<List<Map<String, dynamic>>> getBarberiasStream() {
    return _db
        .collection('barberias')
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList());
  }
}
