import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_window.dart';

class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginWindow()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Inicio del Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenido a BarberStyle 💈',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
