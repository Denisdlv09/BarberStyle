import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/barberias_viewmodel.dart';

import '../admin/dashboard_admin.dart';
import '../cliente/home_cliente.dart';
import 'register_window.dart';
import '../admin/crear_barberia.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({super.key});

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final barberiaVM = context.read<BarberiasViewModel>();

    final user = await authVM.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage ?? "Error al iniciar sesión")),
      );
      return;
    }

    if (user.rol == "cliente") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeCliente()),
      );
      return;
    }

    /// Admin →
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
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Iniciar Sesión", style: AppTextStyles.title),
                  const SizedBox(height: 40),

                  CustomTextField(
                    label: "Correo electrónico",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 15),

                  CustomTextField(
                    label: "Contraseña",
                    controller: _passwordController,
                    isPassword: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 25),

                  authVM.isLoading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : CustomButton(
                    text: "Entrar",
                    onPressed: () => _login(context),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterWindow()),
                      );
                    },
                    child: const Text("¿No tienes cuenta? Regístrate"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
