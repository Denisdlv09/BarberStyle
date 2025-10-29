import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_window.dart';

class RegisterWindow extends StatefulWidget {
  const RegisterWindow({super.key});

  @override
  _RegisterWindowState createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _rolSeleccionado = 'cliente'; // valor por defecto
  bool _isLoading = false;

  Future<void> _register() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Crear usuario en Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guardar información del usuario en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': nombre,
        'email': email,
        'rol': _rolSeleccionado, // 🔹 ahora depende de la selección
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro exitoso")),
      );

      // Ir al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginWindow()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
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
                  'Crear Cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Campos de texto
                _buildTextField(_nombreController, Icons.person, 'Nombre completo'),
                const SizedBox(height: 15),
                _buildTextField(_emailController, Icons.email, 'Correo electrónico'),
                const SizedBox(height: 15),
                _buildTextField(_passwordController, Icons.lock, 'Contraseña', isPassword: true),

                const SizedBox(height: 25),

                // 🔹 Selector de rol
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleOption('cliente', 'Cliente'),
                    const SizedBox(width: 20),
                    _buildRoleOption('admin', 'Admin'),
                  ],
                ),

                const SizedBox(height: 30),

                // Botón de registro
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.redAccent)
                    : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginWindow()),
                    );
                  },
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
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

  /// 🔹 Construye un campo de texto con estilo
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

  /// 🔹 Construye una opción de rol (radio)
  Widget _buildRoleOption(String value, String label) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _rolSeleccionado,
          onChanged: (val) {
            setState(() {
              _rolSeleccionado = val!;
            });
          },
          activeColor: Colors.redAccent,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
