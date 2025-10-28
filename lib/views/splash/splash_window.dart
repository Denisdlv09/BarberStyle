import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../Home/home_window.dart';
import '../Auth/login_window.dart'; // Asegúrate de tener Firebase configurado

class SplashWindow extends StatefulWidget {
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
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _navigateToNextScreen(); // Verificar si el usuario está logueado
  }

  // Método para navegar dependiendo si el usuario está logueado o no
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Retardo de 3 segundos

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Si el usuario está logueado, ir al HomeWindow
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeWindow()),
      );
    } else {
      // Si el usuario no está logueado, ir al LoginWindow
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
            SizedBox(height: 20),
            CircularProgressIndicator(
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
