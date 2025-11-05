import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CitasAdmin extends StatefulWidget {
  final String barberiaId;

  const CitasAdmin({super.key, required this.barberiaId});

  @override
  State<CitasAdmin> createState() => _CitasAdminState();
}

class _CitasAdminState extends State<CitasAdmin> {
  String filtroEstado = "todas"; // todas | pendiente | completada | cancelada
  DateTime? filtroFecha;

  /// 🔹 Formatea la fecha para mostrarla legible
  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Fecha no disponible';
    DateTime dt;
    if (fecha is Timestamp) {
      dt = fecha.toDate();
    } else if (fecha is DateTime) {
      dt = fecha;
    } else {
      try {
        dt = DateTime.parse(fecha.toString());
      } catch (_) {
        return fecha.toString();
      }
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  /// 🔹 Muestra diálogo de confirmación para eliminar cita
  Future<void> _eliminarCita(String citaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Eliminar cita", style: TextStyle(color: Colors.white)),
        content: const Text(
          "¿Estás seguro de eliminar esta cita?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance
            .collection('barberias')
            .doc(widget.barberiaId)
            .collection('citas')
            .doc(citaId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Cita eliminada correctamente")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error al eliminar cita: $e")),
        );
      }
    }
  }

  /// 🔹 Cambia el estado de la cita (por ejemplo, completada)
  Future<void> _actualizarEstado(String citaId, String nuevoEstado) async {
    try {
      await FirebaseFirestore.instance
          .collection('barberias')
          .doc(widget.barberiaId)
          .collection('citas')
          .doc(citaId)
          .update({'estado': nuevoEstado});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Cita marcada como $nuevoEstado")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al actualizar estado: $e")),
      );
    }
  }

  /// 🔹 Filtro por fecha (con DatePicker)
  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: filtroFecha ?? hoy,
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 1),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
        ),
        child: child!,
      ),
    );

    if (seleccionada != null) {
      setState(() => filtroFecha = seleccionada);
    }
  }

  /// 🔹 Limpia los filtros
  void _limpiarFiltros() {
    setState(() {
      filtroEstado = "todas";
      filtroFecha = null;
    });
  }

  /// 🔹 Construcción de la pantalla
  @override
  Widget build(BuildContext context) {
    // CONSULTA: leemos la subcolección de la barbería y ordenamos por fecha.
    // Los filtros se aplicarán en memoria para evitar índices compuestos.
    final Query citasQuery = FirebaseFirestore.instance
        .collection('barberias')
        .doc(widget.barberiaId)
        .collection('citas')
        .orderBy('fecha', descending: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Citas Agendadas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            tooltip: "Filtrar por fecha",
            onPressed: _seleccionarFecha,
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            tooltip: "Filtrar por estado",
            onPressed: () => _mostrarFiltroEstado(context),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            tooltip: "Limpiar filtros",
            onPressed: _limpiarFiltros,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: citasQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ Error al cargar las citas: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay citas para mostrar.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          // Aplicar filtros en memoria (client-side) para evitar índices compuestos.
          final docs = snapshot.data!.docs;
          final List<QueryDocumentSnapshot> filtrados = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // filtro por estado (client-side)
            if (filtroEstado != "todas") {
              final estado = (data['estado'] ?? 'pendiente').toString();
              if (estado != filtroEstado) return false;
            }

            // filtro por fecha (client-side)
            if (filtroFecha != null) {
              dynamic fechaField = data['fecha'];
              DateTime dt;
              if (fechaField is Timestamp) {
                dt = fechaField.toDate();
              } else if (fechaField is DateTime) {
                dt = fechaField;
              } else {
                try {
                  dt = DateTime.parse(fechaField.toString());
                } catch (_) {
                  return false;
                }
              }
              final inicioDia = DateTime(filtroFecha!.year, filtroFecha!.month, filtroFecha!.day);
              final finDia = inicioDia.add(const Duration(days: 1));
              if (!(dt.isAtLeast(inicioDia) && dt.isBefore(finDia))) return false;
            }

            return true;
          }).toList();

          if (filtrados.isEmpty) {
            return const Center(
              child: Text(
                "No hay citas para los filtros seleccionados.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: filtrados.length,
            itemBuilder: (context, index) {
              final cita = filtrados[index];
              final data = cita.data() as Map<String, dynamic>;

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.redAccent),
                  title: Text(
                    data['clienteNombre'] ?? 'Cliente desconocido',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Servicio: ${data['servicio'] ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Fecha: ${_formatearFecha(data['fecha'])}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Estado: ${data['estado'] ?? 'pendiente'}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: Colors.grey[850],
                    onSelected: (opcion) {
                      if (opcion == 'completar') {
                        _actualizarEstado(cita.id, 'completada');
                      } else if (opcion == 'cancelar') {
                        _actualizarEstado(cita.id, 'cancelada');
                      } else if (opcion == 'eliminar') {
                        _eliminarCita(cita.id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'completar',
                        child: Text("✅ Marcar como completada"),
                      ),
                      const PopupMenuItem(
                        value: 'cancelar',
                        child: Text("❌ Marcar como cancelada"),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Text("🗑️ Eliminar cita"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔹 Filtro por estado
  void _mostrarFiltroEstado(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey[900],
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFiltroOpcion("Mostrar todas", "todas"),
          _buildFiltroOpcion("Pendientes", "pendiente"),
          _buildFiltroOpcion("Completadas", "completada"),
          _buildFiltroOpcion("Canceladas", "cancelada"),
        ],
      ),
    );
  }

  /// 🔹 Helper para opciones de filtro
  Widget _buildFiltroOpcion(String texto, String valor) {
    final bool activo = filtroEstado == valor;
    return ListTile(
      title: Text(
        texto,
        style: TextStyle(
          color: activo ? Colors.redAccent : Colors.white70,
          fontWeight: activo ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => filtroEstado = valor);
        Navigator.pop(context);
      },
    );
  }
}

/// 🧩 Helper extension para facilitar comparaciones con DateTime
extension DateCompare on DateTime {
  bool isAtLeast(DateTime other) => !isBefore(other);
}
