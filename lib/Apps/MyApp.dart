import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:barberstyle/Views/HomeWindow.dart';
import 'package:barberstyle/Views/LoginWindow.dart';
import 'package:barberstyle/Views/RegisterWindow.dart';
import 'package:barberstyle/Views/SplashWindow.dart';

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