import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';

import '../../viewmodels/auth_viewmodel.dart';
import 'login_window.dart';

class RegisterWindow extends StatefulWidget {
  const RegisterWindow({super.key});

  @override
  State<RegisterWindow> createState() => _RegisterWindowState();
}

class _RegisterWindowState extends State<RegisterWindow> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _rol = "cliente";

  Future<void> _registrar(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();

    final user = await authVM.register(
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(), // Ahora se envía correctamente
      password: _passwordCtrl.text.trim(),
      rol: _rol,
    );

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? "Error al registrar"),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registro exitoso")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginWindow()),
    );
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
                  Text("Crear Cuenta", style: AppTextStyles.title),
                  const SizedBox(height: 40),

                  // Nombre
                  CustomTextField(
                    label: "Nombre completo",
                    controller: _nombreCtrl,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  CustomTextField(
                    label: "Correo electrónico",
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 15),

                  // Teléfono (nuevo)
                  CustomTextField(
                    label: "Teléfono",
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 15),

                  // Contraseña
                  CustomTextField(
                    label: "Contraseña",
                    controller: _passwordCtrl,
                    isPassword: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 25),

                  // Tipo de usuario
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoleRadio("cliente", "Cliente"),
                      const SizedBox(width: 20),
                      _buildRoleRadio("admin", "Admin"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botón de registro
                  authVM.isLoading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : CustomButton(
                    text: "Registrarse",
                    onPressed: () => _registrar(context),
                  ),

                  const SizedBox(height: 20),

                  // Ir a login
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginWindow()),
                      );
                    },
                    child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleRadio(String value, String label) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _rol,
          onChanged: (v) => setState(() => _rol = v!),
          activeColor: AppColors.primary,
        ),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }
}
