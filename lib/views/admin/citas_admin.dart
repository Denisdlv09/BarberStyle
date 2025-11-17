import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/cita_model.dart';
import '../../viewmodels/citas_viewmodel.dart';

class CitasAdmin extends StatefulWidget {
  final String barberiaId;

  const CitasAdmin({super.key, required this.barberiaId});

  @override
  State<CitasAdmin> createState() => _CitasAdminState();
}

class _CitasAdminState extends State<CitasAdmin> {
  String filtroEstado = "todas";
  DateTime? filtroFecha;

  String _format(DateTime f) => DateFormat('dd/MM/yyyy HH:mm').format(f);

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: filtroFecha ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 1),
      builder: (_, child) => Theme(
        data: ThemeData.dark()
            .copyWith(colorScheme: const ColorScheme.dark(primary: Colors.redAccent)),
        child: child!,
      ),
    );

    if (selected != null) setState(() => filtroFecha = selected);
  }

  void _resetFilters() {
    setState(() {
      filtroEstado = "todas";
      filtroFecha = null;
    });
  }

  void _chooseEstado() {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _estado("Mostrar todas", "todas"),
          _estado("Pendientes", "pendiente"),
          _estado("Completadas", "completada"),
        ],
      ),
    );
  }

  Widget _estado(String txt, String val) {
    return ListTile(
      title: Text(
        txt,
        style: TextStyle(
          color: filtroEstado == val ? Colors.redAccent : Colors.white70,
          fontWeight: filtroEstado == val ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => filtroEstado = val);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _eliminar(CitaModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Eliminar cita", style: TextStyle(color: Colors.white)),
        content: const Text("¿Seguro?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await context.read<CitasViewModel>().eliminarCita(
        barberiaId: widget.barberiaId,
        citaId: c.id,
        clienteId: c.clienteId,
        barberoId: c.barberoId,
      );
    }
  }

  Future<void> _cambiarEstado(CitaModel c, String est) async {
    await context.read<CitasViewModel>().actualizarEstado(
      barberiaId: widget.barberiaId,
      citaId: c.id,
      clienteId: c.clienteId,
      nuevoEstado: est,
      barberoId: c.barberoId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cita marcada como $est")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CitasViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Citas Agendadas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, color: Colors.white),
          ),
          IconButton(
            onPressed: _chooseEstado,
            icon: const Icon(Icons.filter_alt, color: Colors.white),
          ),
          IconButton(
            onPressed: _resetFilters,
            icon: const Icon(Icons.clear_all, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder<List<CitaModel>>(
        stream: vm.getCitasPorBarberia(widget.barberiaId),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          List<CitaModel> citas = snap.data!;

          if (filtroEstado != "todas") {
            citas = citas.where((c) => c.estado == filtroEstado).toList();
          }

          if (filtroFecha != null) {
            final ini = DateTime(filtroFecha!.year, filtroFecha!.month, filtroFecha!.day);
            final fin = ini.add(const Duration(days: 1));
            citas = citas.where((c) => c.fecha.isAfter(ini) && c.fecha.isBefore(fin)).toList();
          }

          if (citas.isEmpty) {
            return const Center(
              child: Text("No hay citas según los filtros.", style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: citas.length,
            itemBuilder: (_, i) {
              final c = citas[i];

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.redAccent),

                  title: Text(
                    c.clienteNombre,
                    style: const TextStyle(color: Colors.white),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Servicio: ${c.servicio}", style: const TextStyle(color: Colors.white70)),
                      Text("Fecha: ${_format(c.fecha)}", style: const TextStyle(color: Colors.white70)),
                      Text("Estado: ${c.estado}", style: const TextStyle(color: Colors.white70)),
                      if (c.barberoNombre.isNotEmpty)
                        Text("Barbero: ${c.barberoNombre}", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (op) {
                      if (op == "completar") _cambiarEstado(c, "completada");
                      if (op == "eliminar") _eliminar(c);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "completar",
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent),
                            SizedBox(width: 10),
                            Text("Marcar como completada", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "eliminar",
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text("Eliminar cita", style: TextStyle(color: Colors.white)),
                          ],
                        ),
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
}
