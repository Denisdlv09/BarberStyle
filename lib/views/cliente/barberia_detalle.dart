import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/barberia_viewmodel.dart';
import 'reservar_cita.dart';
import 'resenar_barberia.dart';

class BarberiaDetalle extends StatelessWidget {
  final String barberiaId;

  const BarberiaDetalle({super.key, required this.barberiaId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BarberiaViewModel()..cargarBarberia(barberiaId),
      child: _BarberiaDetalleBody(barberiaId: barberiaId),
    );
  }
}

class _BarberiaDetalleBody extends StatelessWidget {
  final String barberiaId;

  const _BarberiaDetalleBody({required this.barberiaId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarberiaViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    if (vm.barberiaData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text("No se encontraron datos.", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final data = vm.barberiaData!;
    final nombre = data['nombre'] ?? 'Barbería';
    final direccion = data['direccion'] ?? 'Sin dirección';
    final descripcion = data['descripcion'] ?? 'Sin descripción';
    final imagenLogo = data['imagenLogo'];
    final rating = vm.ratingPromedio;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(nombre, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagenLogo != null && imagenLogo.toString().isNotEmpty
                    ? Image.network(
                  imagenLogo,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 160,
                  height: 160,
                  color: Colors.grey[900],
                  child: const Icon(Icons.store, size: 60, color: Colors.white70),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              nombre,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    direccion,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70),
                )
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Descripción",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              descripcion,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 30),

            // BOTÓN PEDIR CITA
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text("Pedir cita", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReservarCita(
                        barberiaId: barberiaId,
                        barberiaNombre: nombre,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN DEJAR RESEÑA
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: const Icon(Icons.rate_review, color: Colors.white),
                label: const Text("Dejar reseña", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResenarBarberia(
                        barberiaId: barberiaId,
                        barberiaNombre: nombre,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
