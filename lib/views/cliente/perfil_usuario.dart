import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../auth/login_window.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _editando = false;

  @override
  void initState() {
    super.initState();

    final userVM = context.read<UserViewModel>();

    userVM.loadUserData().then((_) {
      final data = userVM.userData;
      if (data != null) {
        _nombreController.text = data['nombre'] ?? '';
        _telefonoController.text = data['telefono'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final user = userVM.userData;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Debes iniciar sesión para ver tu perfil.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Mi Perfil", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await userVM.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginWindow()),
                      (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Avatar
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.redAccent,
                  child: Text(
                    user['nombre']?.isNotEmpty == true
                        ? user['nombre'][0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Email (solo lectura)
                Text(
                  user['email'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Campo nombre
                TextFormField(
                  controller: _nombreController,
                  enabled: _editando,
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null || v.isEmpty ? "Ingresa tu nombre" : null,
                  decoration: _input("Nombre"),
                ),
                const SizedBox(height: 20),

                // Campo teléfono
                TextFormField(
                  controller: _telefonoController,
                  enabled: _editando,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? "Ingresa tu teléfono" : null,
                  decoration: _input("Teléfono"),
                ),
                const SizedBox(height: 30),

                // Botón Guardar o Editar
                _editando
                    ? ElevatedButton.icon(
                  style: _boton(),
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar cambios"),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    await userVM.updateUserData({
                      'nombre': _nombreController.text.trim(),
                      'telefono': _telefonoController.text.trim(),
                    });

                    setState(() => _editando = false);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Perfil actualizado correctamente")),
                      );
                    }
                  },
                )
                    : ElevatedButton.icon(
                  style: _boton(),
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar perfil"),
                  onPressed: () => setState(() => _editando = true),
                ),

                const SizedBox(height: 40),
                const Divider(color: Colors.white24),
                const SizedBox(height: 15),

                // 🔥 Eliminar cuenta
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Eliminar cuenta"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text(
                          "Eliminar cuenta",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        content: const Text(
                          "⚠️ Esta acción eliminará tu cuenta y todas tus citas. ¿Seguro?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar",
                                style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Sí, eliminar",
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await userVM.deleteAccount();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginWindow()),
                              (route) => false,
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  ButtonStyle _boton() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
