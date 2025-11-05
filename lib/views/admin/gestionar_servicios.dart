import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionarServicios extends StatefulWidget {
  final String barberiaId;

  const GestionarServicios({super.key, required this.barberiaId});

  @override
  State<GestionarServicios> createState() => _GestionarServiciosState();
}

class _GestionarServiciosState extends State<GestionarServicios> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();

  bool _isLoading = false;

  /// 🔹 Referencia a la colección de servicios dentro de la barbería
  CollectionReference get serviciosRef => FirebaseFirestore.instance
      .collection('barberias')
      .doc(widget.barberiaId)
      .collection('servicios');

  /// 🔹 Añadir o editar servicio
  Future<void> _guardarServicio({String? servicioId}) async {
    final nombre = _nombreController.text.trim();
    final precioText = _precioController.text.trim();
    final duracionText = _duracionController.text.trim();

    if (nombre.isEmpty || precioText.isEmpty || duracionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final precio = double.tryParse(precioText);
    final duracion = int.tryParse(duracionText);

    if (precio == null || duracion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("El precio y la duración deben ser numéricos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (servicioId == null) {
        // Crear nuevo servicio
        await serviciosRef.add({
          'nombre': nombre,
          'precio': precio,
          'duracion': duracion,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Editar servicio existente
        await serviciosRef.doc(servicioId).update({
          'nombre': nombre,
          'precio': precio,
          'duracion': duracion,
        });
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(servicioId == null
              ? "Servicio añadido correctamente"
              : "Servicio actualizado correctamente"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Mostrar modal para añadir o editar
  void _mostrarDialogoServicio({String? servicioId, Map<String, dynamic>? data}) {
    if (data != null) {
      _nombreController.text = data['nombre'] ?? '';
      _precioController.text = data['precio']?.toString() ?? '';
      _duracionController.text = data['duracion']?.toString() ?? '';
    } else {
      _nombreController.clear();
      _precioController.clear();
      _duracionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            servicioId == null ? "Añadir servicio" : "Editar servicio",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nombreController, 'Nombre del servicio'),
              const SizedBox(height: 10),
              _buildTextField(_precioController, 'Precio (€)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildTextField(_duracionController, 'Duración (minutos)',
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
              const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _guardarServicio(servicioId: servicioId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text(
                _isLoading ? "Guardando..." : "Guardar",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Eliminar servicio
  Future<void> _eliminarServicio(String id) async {
    try {
      await serviciosRef.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Servicio eliminado correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar servicio: $e")),
      );
    }
  }

  /// 🔹 Campo de texto reutilizable
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Gestionar Servicios",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _mostrarDialogoServicio(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: serviciosRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                CircularProgressIndicator(color: Colors.redAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay servicios añadidos todavía.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final servicios = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final servicio = servicios[index];
              final data = servicio.data() as Map<String, dynamic>;

              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.cut, color: Colors.redAccent),
                  title: Text(
                    data['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  subtitle: Text(
                    "€${data['precio']}  |  ${data['duracion']} min",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                        onPressed: () => _mostrarDialogoServicio(
                            servicioId: servicio.id, data: data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _eliminarServicio(servicio.id),
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
