import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/barbero_model.dart';
import '../../data/services/barberos_service.dart';
import '../../viewmodels/barberias_viewmodel.dart';

class BarberosAdmin extends StatelessWidget {
  final String barberiaId;

  const BarberosAdmin({super.key, required this.barberiaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Gestionar Barberos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarDialogoAgregar(context),
      ),
      body: StreamBuilder<List<BarberoModel>>(
        stream: BarberosService().obtenerBarberos(barberiaId),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          final barberos = snap.data!;

          if (barberos.isEmpty) {
            return const Center(
              child: Text("No hay barberos registrados",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: barberos.length,
            itemBuilder: (_, i) {
              final b = barberos[i];

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(b.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    b.activo ? "Activo" : "Inactivo",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: PopupMenuButton<String>(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (op) {
                      if (op == "editar") {
                        _mostrarDialogoEditar(context, b);
                      } else if (op == "eliminar") {
                        _mostrarDialogoEliminar(context, b);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "editar",
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Editar", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "eliminar",
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  //  DIÁLOGO → AGREGAR BARBERO

  void _mostrarDialogoAgregar(BuildContext context) {
    final nombreCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Agregar barbero", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nombreCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Nombre del barbero",
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Guardar"),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              if (nombre.isEmpty) return;

              final barbero = BarberoModel(
                id: "",
                nombre: nombre,
                activo: true,
                createdAt: DateTime.now(),
              );

              final id = await BarberosService().agregarBarbero(
                barberiaId,
                barbero,
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }


  //  DIÁLOGO → EDITAR BARBERO

  void _mostrarDialogoEditar(BuildContext context, BarberoModel barbero) {
    final nombreCtrl = TextEditingController(text: barbero.nombre);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Editar barbero", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nombreCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Nuevo nombre",
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Guardar"),
            onPressed: () async {
              final nuevoNombre = nombreCtrl.text.trim();
              if (nuevoNombre.isEmpty) return;

              final actualizado = barbero.copyWith(nombre: nuevoNombre);

              await BarberosService()
                  .actualizarBarbero(barberiaId, actualizado);

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }


  //  DIÁLOGO → ELIMINAR BARBERO

  void _mostrarDialogoEliminar(BuildContext context, BarberoModel barbero) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Eliminar barbero", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Esto eliminará al barbero y TODAS sus citas.\n¿Estás seguro?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Eliminar"),
            onPressed: () async {
              await BarberosService().eliminarBarbero(
                barberiaId,
                barbero.id!,
                borrarCitas: true,
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
