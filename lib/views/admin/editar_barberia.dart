import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditarBarberia extends StatefulWidget {
  final String barberiaId;

  const EditarBarberia({super.key, required this.barberiaId});

  @override
  State<EditarBarberia> createState() => _EditarBarberiaState();
}

class _EditarBarberiaState extends State<EditarBarberia> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBarberiaData();
  }

  /// 🔹 Cargar los datos actuales de la barbería desde Firestore
  Future<void> _loadBarberiaData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('barberias')
          .doc(widget.barberiaId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nombreController.text = data['nombre'] ?? '';
        _direccionController.text = data['direccion'] ?? '';
        _telefonoController.text = data['telefono'] ?? '';
        _descripcionController.text = data['descripcion'] ?? '';
      }
    } catch (e) {
      print('❌ Error al cargar los datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 💾 Guardar los cambios realizados por el administrador
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('barberias')
          .doc(widget.barberiaId)
          .update({
        'nombre': _nombreController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // 🔙 Vuelve al dashboard
    } catch (e) {
      print('❌ Error al guardar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los cambios: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Editar Barbería',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre de la barbería',
                  icon: Icons.store,
                  validatorMsg: 'Ingresa el nombre de la barbería',
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  icon: Icons.location_on,
                  validatorMsg: 'Ingresa la dirección',
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validatorMsg: 'Ingresa un teléfono válido',
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _descripcionController,
                  label: 'Descripción',
                  icon: Icons.description,
                  maxLines: 4,
                  validatorMsg: 'Agrega una descripción breve',
                ),
                const SizedBox(height: 30),

                _isSaving
                    ? const Center(
                  child: CircularProgressIndicator(
                      color: Colors.redAccent),
                )
                    : ElevatedButton(
                  onPressed: _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                        color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🧱 Construcción de campos reutilizables
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMsg;
        }
        return null;
      },
    );
  }
}
