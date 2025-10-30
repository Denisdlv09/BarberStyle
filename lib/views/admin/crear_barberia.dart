import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_admin.dart';

class CrearBarberia extends StatefulWidget {
  const CrearBarberia({super.key});

  @override
  State<CrearBarberia> createState() => _CrearBarberiaState();
}

class _CrearBarberiaState extends State<CrearBarberia> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isLoading = false;

  Future<void> _crearBarberia() async {
    final nombre = _nombreController.text.trim();
    final direccion = _direccionController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (nombre.isEmpty || direccion.isEmpty || descripcion.isEmpty || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: no hay usuario autenticado")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 🔹 Guardar barbería en Firestore
      await FirebaseFirestore.instance.collection('barberias').add({
        'nombre': nombre,
        'direccion': direccion,
        'descripcion': descripcion,
        'telefono': telefono,
        'propietarioId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Barbería creada correctamente")),
      );

      // 🔹 Redirigir al Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardAdmin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear la barbería: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Crear Barbería"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTextField(_nombreController, Icons.store, "Nombre de la barbería"),
              const SizedBox(height: 15),
              _buildTextField(_direccionController, Icons.location_on, "Dirección"),
              const SizedBox(height: 15),
              _buildTextField(_telefonoController, Icons.phone, "Teléfono"),
              const SizedBox(height: 15),
              _buildTextField(
                _descripcionController,
                Icons.description,
                "Descripción",
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.redAccent)
                  : ElevatedButton.icon(
                onPressed: _crearBarberia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  "Crear Barbería",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
