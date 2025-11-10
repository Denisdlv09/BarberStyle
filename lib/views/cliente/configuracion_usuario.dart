import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_window.dart';

class ConfiguracionUsuario extends StatefulWidget {
  const ConfiguracionUsuario({super.key});

  @override
  State<ConfiguracionUsuario> createState() => _ConfiguracionUsuarioState();
}

class _ConfiguracionUsuarioState extends State<ConfiguracionUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Cargar datos del usuario
  Future<void> _loadUserData() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nombreController.text = data['nombre'] ?? '';
      _telefonoController.text = data['telefono'] ?? '';
    }
  }

  /// 🔹 Guardar cambios del usuario
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() || user == null) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .update({
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cambios guardados correctamente ✅")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("❌ Error al guardar cambios: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al guardar cambios")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 🔹 Eliminar cuenta completamente
  Future<void> _eliminarCuenta() async {
    if (user == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Eliminar cuenta",
            style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          "⚠️ Esta acción eliminará toda tu información, tus citas y tu cuenta. ¿Deseas continuar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
            const Text("Cancelar", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí, eliminar",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    setState(() => _loading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('usuarios').doc(user!.uid);

      // 🔹 1️⃣ Borrar citas dentro de 'usuarios/{uid}/citas'
      final citasUsuario = await userRef.collection('citas').get();
      for (var doc in citasUsuario.docs) {
        final citaData = doc.data();
        final barberiaId = citaData['barberiaId'];

        // 🔹 2️⃣ Eliminar la cita en la barbería correspondiente
        if (barberiaId != null) {
          final citasBarberiaRef =
          firestore.collection('barberias').doc(barberiaId).collection('citas');

          final citasBarberia = await citasBarberiaRef
              .where('clienteId', isEqualTo: user!.uid)
              .get();

          for (var cita in citasBarberia.docs) {
            await cita.reference.delete();
          }
        }

        // 🔹 3️⃣ Eliminar la cita del usuario
        await doc.reference.delete();
      }

      // 🔹 4️⃣ Eliminar documento principal del usuario
      await userRef.delete();

      // 🔹 5️⃣ Eliminar usuario de Firebase Authentication
      await user!.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cuenta eliminada correctamente ✅")),
        );

        // Redirigir al login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginWindow()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("❌ Error al eliminar cuenta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar cuenta")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title:
        const Text("Configuración", style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Actualizar información personal",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Nombre
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Ingresa tu nombre"
                    : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Teléfono
              TextFormField(
                controller: _telefonoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Teléfono",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Ingresa tu teléfono"
                    : null,
              ),
              const SizedBox(height: 30),

              // 🔹 Botón guardar cambios
              ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),

              // 🔹 Botón eliminar cuenta
              ElevatedButton.icon(
                onPressed: _eliminarCuenta,
                icon: const Icon(Icons.delete_forever),
                label: const Text("Eliminar cuenta"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
