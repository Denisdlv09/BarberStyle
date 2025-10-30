import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/dashboard_admin.dart';
import '../admin/crear_barberia.dart';
import '../cliente/home_cliente.dart';
import 'register_window.dart';

class LoginWindow extends StatefulWidget {
  @override
  _LoginWindowState createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔹 Autenticación con Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // 🔹 Obtener datos del usuario desde Firestore
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario no encontrado en la base de datos")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final rol = data['rol'];

      // 🔹 Verificar rol y redirigir
      if (rol == 'admin') {
        // Buscar si ya tiene una barbería registrada
        QuerySnapshot barberiaQuery = await FirebaseFirestore.instance
            .collection('barberias')
            .where('propietarioId', isEqualTo: uid)
            .limit(1)
            .get();

        if (barberiaQuery.docs.isEmpty) {
          // No tiene barbería → redirigir a crear barbería
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CrearBarberia()),
          );
        } else {
          // Ya tiene barbería → redirigir al dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardAdmin()),
          );
        }
      } else {
        // Si es cliente → ir al HomeCliente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeCliente()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ocurrió un error inesperado: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(_emailController, Icons.email, 'Correo electrónico'),
                const SizedBox(height: 15),
                _buildTextField(_passwordController, Icons.lock, 'Contraseña',
                    isPassword: true),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.redAccent)
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterWindow()),
                    );
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
