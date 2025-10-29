import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_window.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

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
        title: const Text('Panel de Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenido al panel del ADMIN',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
