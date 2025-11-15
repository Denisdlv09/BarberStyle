import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/barberias_viewmodel.dart';
import '../auth/login_window.dart';
import '../cliente/home_cliente.dart';
import '../admin/dashboard_admin.dart';
import '../admin/crear_barberia.dart';

class SplashWindow extends StatefulWidget {
  const SplashWindow({super.key});

  @override
  State<SplashWindow> createState() => _SplashWindowState();
}

class _SplashWindowState extends State<SplashWindow>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ));

    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
        ));

    _controller.forward();

    _decidirNavegacion();
  }

  Future<void> _decidirNavegacion() async {
    await Future.delayed(const Duration(seconds: 2));

    final authVM = context.read<AuthViewModel>();
    final barberiaVM = context.read<BarberiasViewModel>();

    final user = await authVM.currentUser();

    if (!mounted) return;

    /// No logeado → Login
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginWindow()),
      );
      return;
    }

    /// Cliente → Home
    if (user.rol == "cliente") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeCliente()),
      );
      return;
    }

    /// Admin → comprobar si tiene barbería
    await barberiaVM.loadBarberiaByAdmin(user.id);

    if (!mounted) return;

    if (barberiaVM.barberiaId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CrearBarberia()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardAdmin()),
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
              builder: (_, child) {
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
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.redAccent),
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
