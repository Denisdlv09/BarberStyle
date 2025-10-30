import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/crear_barberia.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? barberiaData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBarberiaData();
  }

  /// 🔍 Carga la barbería del admin desde Firebase
  Future<void> _loadBarberiaData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('barberias')
          .where('propietarioId', isEqualTo: user!.uid)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          barberiaData = query.docs.first.data();
          isLoading = false;
        });
      } else {
        // Si no tiene barbería creada → lo mandamos a CrearBarberia
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CrearBarberia()),
          );
        }
      }
    } catch (e) {
      print('❌ Error al cargar la barbería: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Panel de Administrador',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : barberiaData == null
          ? const Center(
        child: Text(
          "No se encontró información de la barbería.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo o imagen
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: (barberiaData!['imagenLogo'] != null &&
                  barberiaData!['imagenLogo'].toString().isNotEmpty)
                  ? NetworkImage(barberiaData!['imagenLogo'])
                  : null,
              child: (barberiaData!['imagenLogo'] == null ||
                  barberiaData!['imagenLogo'].toString().isEmpty)
                  ? const Icon(Icons.store, size: 60, color: Colors.white70)
                  : null,
            ),
            const SizedBox(height: 20),

            // Nombre de la barbería
            Text(
              barberiaData!['nombre'] ?? 'Sin nombre',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Dirección
            Text(
              barberiaData!['direccion'] ?? 'Dirección no especificada',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Teléfono
            Text(
              'Tel: ${barberiaData!['telefono'] ?? 'No disponible'}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Descripción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                barberiaData!['descripcion'] ??
                    'No hay descripción disponible.',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Botones de gestión
            _buildActionButton(
              icon: Icons.edit,
              text: "Editar información",
              onPressed: () {
                // 🔹 Aquí luego redirigimos a la pantalla para editar barbería
              },
            ),
            const SizedBox(height: 15),
            _buildActionButton(
              icon: Icons.design_services,
              text: "Gestionar servicios",
              onPressed: () {
                // 🔹 Aquí luego redirigimos a la pantalla de servicios
              },
            ),
            const SizedBox(height: 15),
            _buildActionButton(
              icon: Icons.image,
              text: "Gestionar imágenes",
              onPressed: () {
                // 🔹 Aquí luego añadiremos galería de imágenes
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
        required String text,
        required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
