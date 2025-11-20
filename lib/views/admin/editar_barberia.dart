import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _nuevoBarberoCtrl = TextEditingController();

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _descripcionCtrl.dispose();
    _nuevoBarberoCtrl.dispose();
    super.dispose();
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

  Future<void> _confirmEliminarBarbero(String barberoId, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Eliminar barbero", style: TextStyle(color: Colors.white)),
        content: Text("¿Eliminar a $nombre?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar", style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmar == true) {
      final vm = context.read<BarberiasViewModel>();
      await vm.eliminarBarbero(widget.barberiaId, barberoId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barbero eliminado")));
      }
    }
  }

  Future<void> _editarBarberoDialog(String barberoId, String nombreActual) async {
    final editCtrl = TextEditingController(text: nombreActual);
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Editar barbero", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar", style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Guardar", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (res == true) {
      final vm = context.read<BarberiasViewModel>();
      await vm.editarBarbero(widget.barberiaId, barberoId, editCtrl.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barbero actualizado")));
      }
    }
    editCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarberiasViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Editar Barbería", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _campo(_nombreCtrl, Icons.store, "Nombre"),
                  const SizedBox(height: 15),
                  _campo(_direccionCtrl, Icons.location_on, "Dirección"),
                  const SizedBox(height: 15),
                  _campo(_telefonoCtrl, Icons.phone, "Teléfono"),
                  const SizedBox(height: 15),
                  _campo(_descripcionCtrl, Icons.description, "Descripción", maxLines: 4),
                  const SizedBox(height: 20),
                  vm.isLoading
                      ? const CircularProgressIndicator(color: Colors.redAccent)
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text("Guardar cambios", style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barbería actualizada")));
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),


            //  GESTIÓN DE BARBEROS (lectura en tiempo real)
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Barberos", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            // Añadir nuevo barbero
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nuevoBarberoCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: "Nombre del barbero",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final nombre = _nuevoBarberoCtrl.text.trim();
                    if (nombre.isEmpty) return;
                    await vm.agregarBarbero(widget.barberiaId, nombre);
                    _nuevoBarberoCtrl.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barbero añadido")));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: const Text("Añadir"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Listado a tiempo real de barberos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('barberias')
                    .doc(widget.barberiaId)
                    .collection('barberos')
                    .orderBy('nombre')
                    .snapshots(),
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                  }
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No hay barberos añadidos.", style: TextStyle(color: Colors.white70)));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                    itemBuilder: (_, i) {
                      final d = docs[i];
                      final data = d.data() as Map<String, dynamic>;
                      final barberoId = d.id;
                      final nombre = data['nombre'] ?? '';

                      return ListTile(
                        tileColor: Colors.grey[900],
                        leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(nombre, style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                              onPressed: () => _editarBarberoDialog(barberoId, nombre),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmEliminarBarbero(barberoId, nombre),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, IconData icon, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (v) => (v == null || v.isEmpty) ? "Campo obligatorio" : null,
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
