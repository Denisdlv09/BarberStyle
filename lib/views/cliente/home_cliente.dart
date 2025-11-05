import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔹 Importaciones locales (asegúrate que las rutas existan)
import '../auth/login_window.dart';
import 'barberia_detalle.dart'; // Pantalla de detalle de la barbería

class HomeCliente extends StatefulWidget {
  const HomeCliente({super.key});

  @override
  State<HomeCliente> createState() => _HomeClienteState();
}

class _HomeClienteState extends State<HomeCliente> {
  final user = FirebaseAuth.instance.currentUser;

  /// 🔹 Cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginWindow()),
      );
    }
  }

  /// 🔹 Construcción principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'Barberías disponibles 💈',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar sesión",
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('barberias')
            .orderBy('nombre')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar barberías: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay barberías disponibles aún.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final barberias = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: barberias.length,
            itemBuilder: (context, index) {
              final data = barberias[index].data() as Map<String, dynamic>;
              final barberiaId = barberias[index].id;

              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: (data['imagenLogo'] != null &&
                        data['imagenLogo'].toString().isNotEmpty)
                        ? NetworkImage(data['imagenLogo'])
                        : null,
                    child: (data['imagenLogo'] == null ||
                        data['imagenLogo'].toString().isEmpty)
                        ? const Icon(Icons.store,
                        color: Colors.white70, size: 30)
                        : null,
                  ),
                  title: Text(
                    data['nombre'] ?? 'Barbería sin nombre',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['direccion'] ?? 'Dirección no disponible',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BarberiaDetalle(
                          barberiaId: barberiaId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
