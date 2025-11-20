import 'package:flutter/material.dart';
import 'package:barberstyle/data/services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  Map<String, dynamic>? userData;
  bool isLoading = false;
  String? errorMessage;

  String? get currentUserId => _userService.currentUser?.uid;


  // Cargar datos del usuario

  Future<void> loadUserData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      userData = await _userService.getUserData();
    } catch (e) {
      errorMessage = "Error cargando datos del usuario";
    }

    isLoading = false;
    notifyListeners();
  }


  // Actualizar datos del usuario

  Future<void> updateUserData(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _userService.updateUserData(data);
      await loadUserData();
    } catch (e) {
      errorMessage = "Error actualizando datos";
    }

    isLoading = false;
    notifyListeners();
  }


  // Logout

  Future<void> logout() async {
    await _userService.signOut();
    userData = null;
    notifyListeners();
  }


  // Eliminar cuenta completa

  Future<void> deleteAccount() async {
    await _userService.deleteUserAccount();
    userData = null;
    notifyListeners();
  }


  // Obtener listado de barberías

  Stream<List<Map<String, dynamic>>> getBarberias() {
    return _userService.getBarberiasStream();
  }
}
