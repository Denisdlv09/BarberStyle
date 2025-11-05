import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ResenasAdmin extends StatelessWidget {
  final String barberiaId;

  const ResenasAdmin({super.key, required this.barberiaId});

  String _formatearFecha(Timestamp fecha) {
    final date = fecha.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final barberiaRef =
    FirebaseFirestore.instance.collection('barberias').doc(barberiaId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Reseñas de la Barbería",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // 🔹 Usamos StreamBuilder para mostrar reseñas y mantener todo actualizado
      body: StreamBuilder<DocumentSnapshot>(
        stream: barberiaRef.snapshots(),
        builder: (context, barberiaSnapshot) {
          if (barberiaSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (barberiaSnapshot.hasError || !barberiaSnapshot.hasData) {
            return const Center(
              child: Text(
                "Error al cargar la barbería.",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final barberiaData =
              barberiaSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final ratingPromedio =
          (barberiaData['ratingPromedio'] ?? 0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 Encabezado con el promedio de estrellas
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Promedio: ",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < ratingPromedio.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 22,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ratingPromedio.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: barberiaRef
                      .collection('resenas')
                      .orderBy('fecha', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child:
                        CircularProgressIndicator(color: Colors.redAccent),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "❌ Error al cargar reseñas: ${snapshot.error}",
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 16),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hay reseñas todavía.",
                          style:
                          TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    final resenas = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: resenas.length,
                      itemBuilder: (context, index) {
                        final resena =
                        resenas[index].data() as Map<String, dynamic>;
                        final nombre =
                            resena['nombreCliente'] ?? 'Usuario desconocido';
                        final comentario = resena['comentario'] ?? '';
                        final calificacion = resena['calificacion'] ?? 0;
                        final fecha = resena['fecha'] as Timestamp?;

                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      nombre,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < calificacion
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comentario,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  fecha != null
                                      ? _formatearFecha(fecha)
                                      : 'Sin fecha',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
