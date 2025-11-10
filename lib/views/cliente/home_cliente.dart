import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔹 Importaciones locales
import '../../data/models/cita_model.dart';
import '../auth/login_window.dart';
import 'barberia_detalle.dart';
import 'configuracion_usuario.dart'; // 🔹 Nueva pantalla de configuración

class HomeCliente extends StatefulWidget {
  const HomeCliente({super.key});

  @override
  State<HomeCliente> createState() => _HomeClienteState();
}

class _HomeClienteState extends State<HomeCliente> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Cargar datos del usuario
  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

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

  /// 🔹 Cancelar una cita (elimina en ambas colecciones)
  Future<void> _cancelarCita(CitaModel cita) async {
    try {
      await FirebaseFirestore.instance
          .collection('barberias')
          .doc(cita.barberiaId)
          .collection('citas')
          .doc(cita.id)
          .delete();

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cita.clienteId)
          .collection('citas')
          .doc(cita.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita cancelada correctamente ✅")),
      );
    } catch (e) {
      debugPrint("❌ Error al cancelar cita: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cancelar la cita")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text(
            'Barberías 💈',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.store), text: "Barberías"),
              Tab(icon: Icon(Icons.event), text: "Mis citas"),
            ],
          ),
        ),

        // 🔹 Drawer (menú lateral)
        drawer: Drawer(
          backgroundColor: Colors.grey[900],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.redAccent),
                accountName: Text(
                  userData?['nombre'] ?? 'Usuario',
                  style: const TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  userData?['telefono'] ?? 'Sin teléfono',
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.redAccent),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white70),
                title: const Text("Configuración",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConfiguracionUsuario(),
                    ),
                  ).then((_) => _loadUserData()); // recargar si cambia datos
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Cerrar sesión",
                    style: TextStyle(color: Colors.redAccent)),
                onTap: _logout,
              ),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _buildListaBarberias(),
            _buildMisCitas(),
          ],
        ),
      ),
    );
  }

  /// 🏪 Lista de barberías
  Widget _buildListaBarberias() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('barberias')
          .orderBy('nombre')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error al cargar barberías: ${snapshot.error}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final barberias = snapshot.data?.docs ?? [];

        if (barberias.isEmpty) {
          return const Center(
            child: Text(
              "No hay barberías disponibles aún.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

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
                      color: Colors.white, fontWeight: FontWeight.bold),
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
                      builder: (_) =>
                          BarberiaDetalle(barberiaId: barberiaId),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// 📅 Lista de citas del usuario
  Widget _buildMisCitas() {
    if (user == null) {
      return const Center(
        child: Text(
          "Inicia sesión para ver tus citas.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('citas')
          .orderBy('fecha', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error al cargar citas: ${snapshot.error}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final citas = snapshot.data?.docs ?? [];

        if (citas.isEmpty) {
          return const Center(
            child: Text(
              "No tienes citas programadas.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: citas.length,
          itemBuilder: (context, index) {
            final data = citas[index].data() as Map<String, dynamic>;
            final cita = CitaModel.fromMap(data, citas[index].id);

            final fechaFormateada =
                "${cita.fecha.day.toString().padLeft(2, '0')}/${cita.fecha.month.toString().padLeft(2, '0')}/${cita.fecha.year} "
                "${cita.fecha.hour.toString().padLeft(2, '0')}:${cita.fecha.minute.toString().padLeft(2, '0')}";

            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  data['barberiaNombre'] ?? 'Barbería desconocida',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${cita.servicio}\n📅 $fechaFormateada",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.redAccent),
                  tooltip: "Cancelar cita",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text("Cancelar cita",
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                          "¿Seguro que deseas cancelar esta cita?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("No",
                                style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _cancelarCita(cita);
                            },
                            child: const Text("Sí, cancelar",
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
