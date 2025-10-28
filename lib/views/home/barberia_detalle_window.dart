import 'package:flutter/material.dart';
import 'package:barberstyle/data/models/barberia_model.dart';

class BarberiaDetalleWindow extends StatelessWidget {
  final BarberiaModel barberia;

  const BarberiaDetalleWindow({Key? key, required this.barberia}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(barberia.nombre),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la barbería (placeholder si no hay)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                barberia.imagenUrl.isNotEmpty
                    ? barberia.imagenUrl
                    : 'https://via.placeholder.com/400x200.png?text=Barbería',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Nombre y valoración
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  barberia.nombre,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(barberia.valoracion.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              barberia.direccion,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Teléfono: ${barberia.telefono}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Divider(),

            const Text(
              'Servicios disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Aquí más adelante mostraremos los servicios de esta barbería desde Firestore
            const Text(
              'Próximamente se mostrarán los servicios y citas disponibles.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
