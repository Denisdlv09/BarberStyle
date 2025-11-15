import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/barberias_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditarBarberia extends StatefulWidget {
  final String barberiaId;
  const EditarBarberia({super.key, required this.barberiaId});

  @override
  State<EditarBarberia> createState() => _EditarBarberiaState();
}

class _EditarBarberiaState extends State<EditarBarberia> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final vm = context.read<BarberiasViewModel>();
    final data = vm.barberiaData;

    if (data != null) {
      _nombreCtrl.text = data['nombre'] ?? '';
      _direccionCtrl.text = data['direccion'] ?? '';
      _telefonoCtrl.text = data['telefono'] ?? '';
      _descripcionCtrl.text = data['descripcion'] ?? '';
    }

    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarberiasViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
        const Text("Editar Barbería", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: _cargando
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campo(_nombreCtrl, Icons.store, "Nombre"),
              const SizedBox(height: 15),

              _campo(_direccionCtrl, Icons.location_on, "Dirección"),
              const SizedBox(height: 15),

              _campo(_telefonoCtrl, Icons.phone, "Teléfono"),
              const SizedBox(height: 15),

              _campo(_descripcionCtrl, Icons.description, "Descripción",
                  maxLines: 4),
              const SizedBox(height: 30),

              vm.isLoading
                  ? const CircularProgressIndicator(
                  color: Colors.redAccent)
                  : ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Guardar cambios",
                  style:
                  TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (userId == null) return;

                  await vm.actualizarBarberia(widget.barberiaId, {
                    'nombre': _nombreCtrl.text.trim(),
                    'direccion': _direccionCtrl.text.trim(),
                    'telefono': _telefonoCtrl.text.trim(),
                    'descripcion': _descripcionCtrl.text.trim(),
                    'propietarioId': userId,
                    'ultimaActualizacion': DateTime.now(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, IconData icon, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (v) =>
      (v == null || v.isEmpty) ? "Campo obligatorio" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
