import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barberstyle/Views/Home/home_window.dart';
import 'register_window.dart';

class LoginWindow extends StatefulWidget {
  @override
  _LoginWindowState createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[800]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título
                  Text(
                    "Barber Style",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Campo de Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Campo de Contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Botón de Iniciar Sesión
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text(
                      "Iniciar Sesión",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Texto de "¿No tienes cuenta?"
                  MouseRegion(
                    onEnter: (_) => _showUnderline(context, true),
                    onExit: (_) => _showUnderline(context, false),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterWindow()),
                        );
                      },
                      child: Text(
                        "¿No tienes cuenta? Regístrate aquí",
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      // Obtener los valores de los campos de texto
      final email = _emailController.text;
      final password = _passwordController.text;

      // Intentar iniciar sesión con Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si el inicio de sesión es exitoso, navegar a HomeView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeWindow()),
      );
    } catch (e) {
      // Si ocurre un error, mostrar un mensaje
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Hubo un error al iniciar sesión: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  void _showUnderline(BuildContext context, bool isHovered) {
    // Actualiza el estilo de texto para subrayarlo
    final style = isHovered
        ? TextStyle(color: Colors.white, decoration: TextDecoration.underline)
        : TextStyle(color: Colors.white70, decoration: TextDecoration.none);
  }
}
