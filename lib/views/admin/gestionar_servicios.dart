import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/servicios_viewmodel.dart';
import '../../data/models/servicio_model.dart';

class GestionarServicios extends StatefulWidget {
  final String barberiaId;

  const GestionarServicios({super.key, required this.barberiaId});

  @override
  State<GestionarServicios> createState() => _GestionarServiciosState();
}

class _GestionarServiciosState extends State<GestionarServicios> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();

  void _mostrarDialogo({ServicioModel? servicio}) {
    if (servicio != null) {
      _nombre.text = servicio.nombre;
      _precio.text = servicio.precio.toString();
    } else {
      _nombre.clear();
      _precio.clear();
    }

    showDialog(
      context: context,
      builder: (context) => Consumer<ServiciosViewModel>(
        builder: (_, vm, __) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              servicio == null ? "Añadir Servicio" : "Editar Servicio",
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campo(_nombre, "Nombre del servicio"),
                const SizedBox(height: 10),
                _campo(_precio, "Precio (€)", keyboard: TextInputType.number),

                const SizedBox(height: 15),
                const Text(
                  "⏱ La duración será siempre 30 minutos.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: vm.isLoading
                    ? null
                    : () async {
                  final nombre = _nombre.text.trim();
                  final precio = double.tryParse(_precio.text.trim());

                  if (nombre.isEmpty || precio == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Completa todos los campos correctamente"),
                      ),
                    );
                    return;
                  }

                  if (servicio == null) {
                    await vm.agregarServicio(
                      widget.barberiaId,
                      nombre,
                      precio,
                    );
                  } else {
                    await vm.editarServicio(
                      widget.barberiaId,
                      servicio.id,
                      nombre,
                      precio,
                    );
                  }

                  if (mounted) Navigator.pop(context);
                },
                child: Text(
                  vm.isLoading ? "Guardando..." : "Guardar",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiciosViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Gestionar Servicios", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            onPressed: () => _mostrarDialogo(),
            icon: const Icon(Icons.add, color: Colors.white),
          )
        ],
      ),
      body: StreamBuilder<List<ServicioModel>>(
        stream: vm.getServicios(widget.barberiaId),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent));
          }

          final servicios = snapshot.data!;
          if (servicios.isEmpty) {
            return const Center(
              child: Text("No hay servicios añadidos.",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: servicios.length,
            itemBuilder: (_, i) {
              final s = servicios[i];
              return Card(
                color: Colors.grey[900],
                child: ListTile(
                  leading: const Icon(Icons.cut, color: Colors.redAccent),
                  title: Text(s.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "€${s.precio} | 30 min",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                        onPressed: () => _mostrarDialogo(servicio: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await vm.eliminarServicio(widget.barberiaId, s.id);
                        },
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
}
