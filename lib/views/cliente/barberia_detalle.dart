import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Importaciones locales
import 'resenar_barberia.dart'; // ✅ para dejar reseñas
import 'reservar_cita.dart'; // ✅ para pedir cita

class BarberiaDetalle extends StatefulWidget {
  final String barberiaId;

  const BarberiaDetalle({
    super.key,
    required this.barberiaId,
  });

  @override
  State<BarberiaDetalle> createState() => _BarberiaDetalleState();
}

class _BarberiaDetalleState extends State<BarberiaDetalle> {
  Map<String, dynamic>? barberiaData;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosBarberia();
  }

  Future<void> _cargarDatosBarberia() async {
    final doc = await FirebaseFirestore.instance
        .collection('barberias')
        .doc(widget.barberiaId)
        .get();

    if (doc.exists) {
      setState(() {
        barberiaData = doc.data();
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    if (barberiaData == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No se encontraron los datos de esta barbería.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final nombre = barberiaData!['nombre'] ?? 'Barbería sin nombre';
    final direccion = barberiaData!['direccion'] ?? 'Sin dirección';
    final descripcion = barberiaData!['descripcion'] ?? 'Sin descripción';
    final imagenLogo = barberiaData!['imagenLogo'];
    final rating = (barberiaData!['ratingPromedio'] ?? 0).toDouble();

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
            // 🔹 Imagen o ícono de barbería
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagenLogo != null && imagenLogo.isNotEmpty
                    ? Image.network(
                  imagenLogo,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey[900],
                  child: const Icon(Icons.store,
                      color: Colors.white70, size: 60),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    direccion,
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 5),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Descripción",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // 🔹 Botón para pedir cita
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReservarCita(
                        barberiaId: widget.barberiaId,
                        barberiaNombre: nombre,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text(
                  "Pedir cita",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Botón para dejar reseña
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResenarBarberia(
                        barberiaId: widget.barberiaId,
                        barberiaNombre: nombre,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review, color: Colors.white),
                label: const Text(
                  "Dejar una reseña",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
