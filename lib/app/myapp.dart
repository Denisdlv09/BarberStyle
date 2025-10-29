import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔹 Importa las nuevas pantallas
import 'package:barberstyle/views/auth/login_window.dart';
import 'package:barberstyle/views/auth/register_window.dart';
import 'package:barberstyle/views/splash/splash_window.dart';
import 'package:barberstyle/views/cliente/home_cliente.dart';
import 'package:barberstyle/views/admin/dashboard_admin.dart';

import 'package:barberstyle/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barber Style',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      // 🟢 Pantalla inicial
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashWindow(),
        '/login': (context) => LoginWindow(),
        '/register': (context) => RegisterWindow(),
        '/home_cliente': (context) => const HomeCliente(),
        '/dashboard_admin': (context) => const DashboardAdmin(),
      },
    );
  }
}
