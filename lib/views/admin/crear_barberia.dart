import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../viewmodels/barberias_viewmodel.dart';
import 'dashboard_admin.dart';

class CrearBarberia extends StatefulWidget {
  const CrearBarberia({super.key});

  @override
  State<CrearBarberia> createState() => _CrearBarberiaState();
}

class _CrearBarberiaState extends State<CrearBarberia> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  /// 🔥 Lista de barberos nuevos
  final List<TextEditingController> _barberosCtrl = [];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _descripcionCtrl.dispose();
    for (var c in _barberosCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _agregarBarbero() {
    setState(() {
      _barberosCtrl.add(TextEditingController());
    });
  }

  void _eliminarBarbero(int index) {
    setState(() {
      _barberosCtrl[index].dispose();
      _barberosCtrl.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarberiasViewModel>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Crear Barbería", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                _field(_nombreCtrl, Icons.store, "Nombre de la barbería"),
                const SizedBox(height: 15),

                _field(_direccionCtrl, Icons.location_on, "Dirección"),
                const SizedBox(height: 15),

                _field(_telefonoCtrl, Icons.phone, "Teléfono"),
                const SizedBox(height: 15),

                _field(_descripcionCtrl, Icons.description, "Descripción", maxLines: 3),
                const SizedBox(height: 30),

                // -------------------------------------------------
                //  🔥 LISTA DE BARBEROS
                // -------------------------------------------------
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Barberos",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                Column(
                  children: _barberosCtrl.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ctrl = entry.value;

                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ctrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white10,
                              labelText: "Nombre del barbero",
                              labelStyle: const TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _eliminarBarbero(index),
                        )
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: _agregarBarbero,
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text("Añadir barbero", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                ),

                const SizedBox(height: 30),

                // -------------------------------------------------
                //  BOTÓN CREAR
                // -------------------------------------------------
                vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.redAccent)
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    "Crear Barbería",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (user == null) return;

                    // Datos principales
                    final barberiaData = {
                      'nombre': _nombreCtrl.text.trim(),
                      'direccion': _direccionCtrl.text.trim(),
                      'descripcion': _descripcionCtrl.text.trim(),
                      'telefono': _telefonoCtrl.text.trim(),
                      'propietarioId': user.uid,
                      'createdAt': DateTime.now(),
                    };

                    // Crear barbería y obtener ID
                    final barberiaId = await vm.crearBarberia(barberiaData);

                    if (barberiaId != null) {
                      // Guardar barberos
                      for (var ctrl in _barberosCtrl) {
                        if (ctrl.text.trim().isEmpty) continue;

                        await vm.agregarBarbero(
                          barberiaId,
                          ctrl.text.trim(),
                        );
                      }

                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const DashboardAdmin()),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, IconData i, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (v) => (v == null || v.isEmpty) ? "Campo obligatorio" : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        prefixIcon: Icon(i, color: Colors.white),
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
