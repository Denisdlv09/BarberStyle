import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ResenasAdmin extends StatelessWidget {
  final String barberiaId;

  const ResenasAdmin({super.key, required this.barberiaId});

  String _format(Timestamp t) =>
      DateFormat('dd/MM/yyyy HH:mm').format(t.toDate());

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('barberias').doc(barberiaId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Reseñas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: ref.snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final rating = (data["ratingPromedio"] ?? 0).toDouble();

          return Column(
            children: [
              _ratingHeader(rating),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: ref
                      .collection('resenas')
                      .orderBy('fecha', descending: true)
                      .snapshots(),
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.redAccent),
                      );
                    }

                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hay reseñas aún",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final r = docs[i].data() as Map<String, dynamic>;
                        return _item(r);
                      },
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _ratingHeader(double rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Promedio: ",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          Row(
            children: List.generate(
              5,
                  (i) => Icon(
                i < rating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _item(Map<String, dynamic> r) {
    final puntuacion = (r["puntuacion"] ?? 0).toDouble();

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r["nombreCliente"] ?? "Cliente",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < puntuacion ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              r["comentario"] ?? "",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              r["fecha"] != null ? _format(r["fecha"]) : "",
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
