import 'package:flutter/material.dart';

class RegisterWindow extends StatefulWidget {
  @override
  _RegisterWindowState createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
                    "Barber Style - Registro",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Campo de Nombre
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

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
                  SizedBox(height: 15),

                  // Campo de Confirmación de Contraseña
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Botón de Registro
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text(
                      "Registrarse",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Texto de "¿Ya tienes cuenta?"
                  MouseRegion(
                    onEnter: (_) => _showUnderline(context, true),
                    onExit: (_) => _showUnderline(context, false),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "¿Ya tienes cuenta? Inicia sesión aquí",
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

  Future<void> _register() async {
    // Aquí se puede agregar la lógica de registro (por ejemplo, con Firebase)
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      // Si las contraseñas no coinciden, muestra un error
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Las contraseñas no coinciden.'),
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
    } else {
      // Lógica de registro (aquí debería ir la integración con Firebase)
      // Ejemplo:
      // FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
    }
  }

  void _showUnderline(BuildContext context, bool isHovered) {
    // Este método cambia el estilo visual al pasar el mouse
    final style = isHovered
        ? TextStyle(color: Colors.white, decoration: TextDecoration.underline)
        : TextStyle(color: Colors.white70, decoration: TextDecoration.none);

    // Este estilo podría aplicarse a un widget si fuera necesario
  }
}
