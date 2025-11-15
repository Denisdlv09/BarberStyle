import 'package:flutter/material.dart';
import 'package:barberstyle/data/models/user_model.dart';
import 'package:barberstyle/data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _user;
  UserModel? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // -------------------------------------------------------
  // Helpers internos
  // -------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setUser(UserModel? newUser) {
    _user = newUser;
    notifyListeners();
  }

  // -------------------------------------------------------
  // 🔹 Método necesario en SplashScreen
  // -------------------------------------------------------

  Future<UserModel?> currentUser() async {
    final user = await _authService.getCurrentUser();

    if (user != null) {
      _setUser(user);
    }

    return user;
  }

  // -------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------

  Future<UserModel?> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signIn(email, password);

      if (user == null) {
        _setError("Usuario o contraseña incorrectos");
      } else {
        _setUser(user);
      }

      return user;
    } catch (e) {
      _setError("Error al iniciar sesión");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------------------------------------
  // REGISTRO
  // -------------------------------------------------------

  Future<UserModel?> register({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String rol,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.register(
        nombre: nombre,
        email: email,
        telefono: telefono,
        password: password,
        rol: rol,
      );

      if (user == null) {
        _setError("No se pudo registrar el usuario");
      } else {
        _setUser(user);
      }

      return user;
    } catch (e) {
      _setError("Error al registrar usuario");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------

  Future<void> logout() async {
    await _authService.signOut();
    _setUser(null);
  }
}
