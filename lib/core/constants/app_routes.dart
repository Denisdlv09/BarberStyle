/// 🗺️ Rutas centralizadas de la aplicación
class AppRoutes {
  AppRoutes._(); // Evita instanciación

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String homeCliente = '/home_cliente';
  static const String dashboardAdmin = '/dashboard_admin';

  // Opcionales si los usas:
  static const String configuracionUsuario = '/configuracion_usuario';
  static const String barberiaDetalle = '/barberia_detalle';
  static const String reservarCita = '/reservar_cita';
  static const String resenarBarberia = '/resenar_barberia';
}
