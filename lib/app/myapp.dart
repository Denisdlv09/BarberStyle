import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  ViewModels
import 'package:barberstyle/viewmodels/auth_viewmodel.dart';
import 'package:barberstyle/viewmodels/user_viewmodel.dart';
import 'package:barberstyle/viewmodels/citas_viewmodel.dart';
import 'package:barberstyle/viewmodels/barberias_viewmodel.dart';

//  Vistas principales
import 'package:barberstyle/views/splash/splash_window.dart';
import 'package:barberstyle/views/auth/login_window.dart';
import 'package:barberstyle/views/auth/register_window.dart';
import 'package:barberstyle/views/cliente/home_cliente.dart';
import 'package:barberstyle/views/admin/dashboard_admin.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CitasViewModel()),
        ChangeNotifierProvider(create: (_) => BarberiasViewModel()),
      ],
      child: MaterialApp(
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

        //  Pantalla inicial
        initialRoute: '/splash',

        routes: {
          '/splash': (context) => SplashWindow(),
          '/login': (context) => const LoginWindow(),
          '/register': (context) => const RegisterWindow(),
          '/home_cliente': (context) => const HomeCliente(),
          '/dashboard_admin': (context) => const DashboardAdmin(),
        },
      ),
    );
  }
}
