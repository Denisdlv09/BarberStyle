import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../viewmodels/barberias_viewmodel.dart';
import '../auth/login_window.dart';
import 'crear_barberia.dart';
import 'editar_barberia.dart';
import 'gestionar_servicios.dart';
import 'citas_admin.dart';
import 'resenas_admin.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<BarberiasViewModel>().loadBarberiaByAdmin(user.uid);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginWindow()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarberiasViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    if (vm.barberiaData == null) {
      return const CrearBarberia();
    }

    final data = vm.barberiaData!;
    final id = vm.barberiaId!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          "Panel de Administrador",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          )
        ],
      ),
      body: _buildContent(data, id),
    );
  }

  Widget _buildContent(Map<String, dynamic> data, String id) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: (data['imagenLogo'] != null &&
                data['imagenLogo'].toString().isNotEmpty)
                ? NetworkImage(data['imagenLogo'])
                : null,
            child: (data['imagenLogo'] == null ||
                data['imagenLogo'].toString().isEmpty)
                ? const Icon(Icons.store, size: 60, color: Colors.white70)
                : null,
          ),
          const SizedBox(height: 20),

          Text(
            data['nombre'] ?? 'Sin nombre',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            data['direccion'] ?? 'Dirección no especificada',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),

          Text(
            'Tel: ${data['telefono'] ?? 'No disponible'}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),

          _descriptionBox(data['descripcion'] ?? "Sin descripción"),

          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          _buildButton(Icons.edit, "Editar información", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditarBarberia(barberiaId: id),
              ),
            );
          }),

          const SizedBox(height: 15),
          _buildButton(Icons.design_services, "Gestionar servicios", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GestionarServicios(barberiaId: id),
              ),
            );
          }),

          const SizedBox(height: 15),
          _buildButton(Icons.calendar_month, "Ver citas", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CitasAdmin(barberiaId: id),
              ),
            );
          }),

          const SizedBox(height: 15),
          _buildButton(Icons.reviews, "Ver reseñas", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResenasAdmin(barberiaId: id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _descriptionBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildButton(IconData icon, String text, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
