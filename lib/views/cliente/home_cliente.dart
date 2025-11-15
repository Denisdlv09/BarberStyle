import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/citas_viewmodel.dart';
import '../../data/models/cita_model.dart';

import '../auth/login_window.dart';
import 'barberia_detalle.dart';
import 'perfil_usuario.dart';

class HomeCliente extends StatefulWidget {
  const HomeCliente({super.key});

  @override
  State<HomeCliente> createState() => _HomeClienteState();
}

class _HomeClienteState extends State<HomeCliente> {
  @override
  void initState() {
    super.initState();

    // Cargar datos del usuario en cuanto se monta la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final citasVM = context.watch<CitasViewModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title:
          const Text('Barberías 💈', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.store), text: "Barberías"),
              Tab(icon: Icon(Icons.event), text: "Mis citas"),
            ],
          ),
        ),

        // Drawer
        drawer: Drawer(
          backgroundColor: Colors.grey[900],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.redAccent),
                accountName: Text(
                  userVM.userData?['nombre'] ?? 'Usuario',
                  style: const TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  userVM.userData?['telefono'] ?? 'Sin teléfono',
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.redAccent),
                ),
              ),

              // PERFIL / CONFIGURACIÓN
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white70),
                title: const Text("Mi perfil",
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PerfilUsuario()),
                  );

                  // Recargar datos al volver
                  userVM.loadUserData();
                },
              ),

              const Divider(color: Colors.white24),

              // LOGOUT
              ListTile(
                leading:
                const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Cerrar sesión",
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  await userVM.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginWindow()),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // Contenido de Tabs
        body: TabBarView(
          children: [
            _buildListaBarberias(),
            _buildMisCitas(citasVM),
          ],
        ),
      ),
    );
  }

  /// 🏪 Listado de barberías
  Widget _buildListaBarberias() {
    return Consumer<UserViewModel>(
      builder: (context, userVM, _) {
        return StreamBuilder(
          stream: userVM.getBarberias(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent));
            }

            final barberias = snapshot.data ?? [];
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
                final data = barberias[index];

                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: (data['imagenLogo']?.isNotEmpty ?? false)
                          ? NetworkImage(data['imagenLogo'])
                          : null,
                      child: (data['imagenLogo'] == null ||
                          data['imagenLogo'].isEmpty)
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
                      style:
                      const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white70),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BarberiaDetalle(barberiaId: data['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// 📅 Mis citas
  Widget _buildMisCitas(CitasViewModel citasVM) {
    final userId = context.read<UserViewModel>().currentUserId;

    if (userId == null) {
      return const Center(
        child: Text("Inicia sesión para ver tus citas.",
            style: TextStyle(color: Colors.white70)),
      );
    }

    return StreamBuilder<List<CitaModel>>(
      stream: citasVM.getCitasPorUsuario(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent));
        }

        final citas = snapshot.data!;
        if (citas.isEmpty) {
          return const Center(
            child: Text("No tienes citas programadas.",
                style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: citas.length,
          itemBuilder: (context, index) {
            final cita = citas[index];

            final fechaFormateada =
                "${cita.fecha.day.toString().padLeft(2, '0')}/${cita.fecha.month.toString().padLeft(2, '0')}/${cita.fecha.year} "
                "${cita.fecha.hour.toString().padLeft(2, '0')}:${cita.fecha.minute.toString().padLeft(2, '0')}";

            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  cita.servicio,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("📅 $fechaFormateada",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
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
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text("No",
                                style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text("Sí, cancelar",
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await citasVM.cancelarCita(cita);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Cita cancelada correctamente")),
                        );
                      }
                    }
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
