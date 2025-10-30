import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Importaciones
import '../auth/login_window.dart';
import '../cliente/home_cliente.dart';
import '../admin/dashboard_admin.dart';
import '../admin/crear_barberia.dart';

class SplashWindow extends StatefulWidget {
  const SplashWindow({super.key});

  @override
  _SplashWindowState createState() => _SplashWindowState();
}

class _SplashWindowState extends State<SplashWindow> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _navigateToNextScreen();
  }

  /// 🔍 Verifica el rol del usuario en Firestore y redirige
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No hay sesión iniciada → Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginWindow()),
      );
      return;
    }

    try {
      // Consultamos Firestore para saber su rol y barbería
      final userDoc =
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final String rol = data?['rol'] ?? 'cliente';
        final String? barberiaId = data?['barberiaId'];

        if (rol == 'admin') {
          // Si es admin, comprobamos si tiene barbería creada
          if (barberiaId == null || barberiaId.isEmpty) {
            // No tiene barbería aún → pantalla de creación
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CrearBarberia()),
            );
          } else {
            // Ya tiene barbería → dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardAdmin()),
            );
          }
        } else {
          // Si es cliente → pantalla principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeCliente()),
          );
        }
      } else {
        // Si no existe documento, lo tratamos como cliente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeCliente()),
        );
      }
    } catch (e) {
      print('❌ Error al verificar el rol o barbería: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginWindow()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/Logo Barber Style.jpg',
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
