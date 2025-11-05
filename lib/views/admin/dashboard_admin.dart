import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔹 Importaciones de pantallas
import '../admin/crear_barberia.dart';
import '../admin/editar_barberia.dart';
import '../admin/gestionar_servicios.dart';
import '../admin/resenas_admin.dart';
import '../admin/citas_admin.dart';
import '../auth/login_window.dart'; // ✅ Importamos para volver tras cerrar sesión

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? barberiaData;
  String? barberiaId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBarberiaData();
  }

  /// 🔍 Carga la barbería asociada al administrador desde Firestore
  Future<void> _loadBarberiaData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('barberias')
          .where('propietarioId', isEqualTo: user!.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          barberiaData = query.docs.first.data();
          barberiaId = query.docs.first.id;
          isLoading = false;
        });
      } else {
        // 🔸 Si el admin no tiene barbería creada → ir a crearla
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CrearBarberia()),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error al cargar la barbería: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la barbería: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Cierra sesión correctamente y redirige al login
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginWindow()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("❌ Error al cerrar sesión: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cerrar sesión: $e")),
        );
      }
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
            onPressed: () => _logout(context), // ✅ corregido
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
            // 🔹 Imagen / Logo de la barbería
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: (barberiaData!['imagenLogo'] != null &&
                  barberiaData!['imagenLogo'].toString().isNotEmpty)
                  ? NetworkImage(barberiaData!['imagenLogo'])
                  : null,
              child: (barberiaData!['imagenLogo'] == null ||
                  barberiaData!['imagenLogo'].toString().isEmpty)
                  ? const Icon(Icons.store,
                  size: 60, color: Colors.white70)
                  : null,
            ),
            const SizedBox(height: 20),

            // 🔹 Nombre
            Text(
              barberiaData!['nombre'] ?? 'Sin nombre',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Dirección
            Text(
              barberiaData!['direccion'] ??
                  'Dirección no especificada',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // 🔹 Teléfono
            Text(
              'Tel: ${barberiaData!['telefono'] ?? 'No disponible'}',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // 🔹 Descripción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                barberiaData!['descripcion'] ??
                    'No hay descripción disponible.',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 20),

            // 🔹 Botones de gestión
            _buildActionButton(
              icon: Icons.edit,
              text: "Editar información",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditarBarberia(barberiaId: barberiaId!),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            _buildActionButton(
              icon: Icons.design_services,
              text: "Gestionar servicios",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GestionarServicios(barberiaId: barberiaId!),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            _buildActionButton(
              icon: Icons.calendar_month,
              text: "Ver citas",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CitasAdmin(barberiaId: barberiaId!),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            _buildActionButton(
              icon: Icons.reviews,
              text: "Ver reseñas",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ResenasAdmin(barberiaId: barberiaId!),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔘 Constructor de botones reutilizable
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
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
