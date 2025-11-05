import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_window.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({super.key});

  @override
  State<PerfilCliente> createState() => _PerfilClienteState();
}

class _PerfilClienteState extends State<PerfilCliente> {
  final user = FirebaseAuth.instance.currentUser;
  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  bool _editando = false;
  bool _guardando = false;

  /// 🔹 Carga los datos del usuario desde Firestore
  Future<void> _cargarDatos() async {
    if (user == null) return;
    final doc =
    await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nombreCtrl.text = data['nombre'] ?? '';
      telefonoCtrl.text = data['telefono'] ?? '';
    }
  }

  /// 🔹 Guarda los datos actualizados
  Future<void> _guardarCambios() async {
    if (user == null) return;
    setState(() => _guardando = true);
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).update({
        'nombre': nombreCtrl.text.trim(),
        'telefono': telefonoCtrl.text.trim(),
      });
      setState(() => _editando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Perfil actualizado correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar cambios: $e")),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  /// 🔹 Cierra la sesión
  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginWindow()),
            (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.redAccent,
                child: Text(
                  nombreCtrl.text.isNotEmpty
                      ? nombreCtrl.text[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user!.email ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: nombreCtrl,
                enabled: _editando,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: telefonoCtrl,
                enabled: _editando,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Teléfono",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _editando
                  ? _guardando
                  ? const CircularProgressIndicator(color: Colors.redAccent)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                    onPressed: _guardarCambios,
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.white70),
                    label: const Text("Cancelar",
                        style: TextStyle(color: Colors.white70)),
                    onPressed: () {
                      setState(() => _editando = false);
                      _cargarDatos();
                    },
                  ),
                ],
              )
                  : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                ),
                icon: const Icon(Icons.edit),
                label: const Text("Editar Perfil"),
                onPressed: () => setState(() => _editando = true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
