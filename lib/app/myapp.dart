import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:barberstyle/Views/Home/home_window.dart';
import 'package:barberstyle/Views/Auth/login_window.dart';
import 'package:barberstyle/Views/Auth/register_window.dart';
import 'package:barberstyle/Views/Splash/splash_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber Style',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splashview',  // Ruta inicial para el SplashView
      routes: {
        '/loginview': (context) =>  LoginWindow(),
        '/homeview': (context) =>  HomeWindow(),
        '/registerview': (context) => RegisterWindow(),
        '/splashview': (context) => SplashWindow(),
      },
    );
  }
}