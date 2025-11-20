import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'App/myapp.dart';
import 'firebase_options.dart';

//  ViewModels globales
import 'package:barberstyle/viewmodels/auth_viewmodel.dart';
import 'package:barberstyle/viewmodels/user_viewmodel.dart';
import 'package:barberstyle/viewmodels/citas_viewmodel.dart';
import 'package:barberstyle/viewmodels/barberias_viewmodel.dart';
import 'package:barberstyle/viewmodels/servicios_viewmodel.dart';
import 'package:barberstyle/viewmodels/resenas_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //  MultiProvider con todos los ViewModels necesarios
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CitasViewModel()),
        ChangeNotifierProvider(create: (_) => BarberiasViewModel()),
        ChangeNotifierProvider(create: (_) => ServiciosViewModel()),
        ChangeNotifierProvider(create: (_) => ResenasViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
