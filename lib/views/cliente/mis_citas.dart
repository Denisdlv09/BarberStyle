import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MisCitas extends StatefulWidget {
  const MisCitas({super.key});

  @override
  State<MisCitas> createState() => _MisCitasState();
}

class _MisCitasState extends State<MisCitas> {
  final user = FirebaseAuth.instance.currentUser;

  ///  Cancela una cita (actualiza su estado)
  Future<void> _cancelarCita(String citaId) async {
    try {
      await FirebaseFirestore.instance.collection('citas').doc(citaId).update({
        'estado': 'cancelada',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Cita cancelada correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cancelar cita: $e")),
      );
    }
  }

  ///  Formatea la fecha
  String _formatearFecha(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Debes iniciar sesión para ver tus citas.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          "Mis Citas",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('citas')
            .where('clienteId', isEqualTo: user!.uid)
            .orderBy('fecha', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tienes citas reservadas aún.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final citas = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index];
              final data = cita.data() as Map<String, dynamic>;

              final estado = data['estado'] ?? 'pendiente';
              final fecha = data['fecha'] != null
                  ? _formatearFecha(data['fecha'])
                  : 'Sin fecha';
              final servicio = data['servicio'] ?? 'Servicio';
              final barberia = data['barberiaNombre'] ?? 'Barbería';

              Color colorEstado;
              switch (estado) {
                case 'confirmada':
                  colorEstado = Colors.greenAccent;
                  break;
                case 'cancelada':
                  colorEstado = Colors.redAccent;
                  break;
                default:
                  colorEstado = Colors.orangeAccent;
              }

              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.redAccent),
                  title: Text(
                    barberia,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        servicio,
                        style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fecha,
                        style:
                        const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            "Estado: ",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            estado.toUpperCase(),
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: estado == 'pendiente'
                      ? IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.redAccent),
                    tooltip: "Cancelar cita",
                    onPressed: () => _cancelarCita(cita.id),
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
