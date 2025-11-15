import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/reservar_cita_viewmodel.dart';
import '..//widgets/servicio_dropdown.dart';
import '..//widgets/horas_disponibles.dart';

class ReservarCita extends StatelessWidget {
  final String barberiaId;
  final String barberiaNombre;

  const ReservarCita({
    super.key,
    required this.barberiaId,
    required this.barberiaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReservarCitaViewModel(),
      child: _ReservarCitaView(barberiaId: barberiaId, barberiaNombre: barberiaNombre),
    );
  }
}

class _ReservarCitaView extends StatelessWidget {
  final String barberiaId;
  final String barberiaNombre;

  const _ReservarCitaView({
    required this.barberiaId,
    required this.barberiaNombre,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReservarCitaViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Reservar en $barberiaNombre", style: const TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ------------------ SERVICIOS ------------------
            const Text("Servicio:", style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('barberias')
                  .doc(barberiaId)
                  .collection('servicios')
                  .orderBy('nombre')
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                }

                final servicios = snap.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();

                return ServicioDropdown(
                  servicios: servicios,
                  valorSeleccionado: vm.servicioSeleccionado,
                  onChanged: vm.seleccionarServicio,
                );
              },
            ),

            const SizedBox(height: 20),

            // ------------------ FECHA ------------------
            const Text("Fecha:", style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                vm.fechaSeleccionada == null
                    ? "Elegir fecha"
                    : DateFormat('dd/MM/yyyy').format(vm.fechaSeleccionada!),
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final hoy = DateTime.now();
                final seleccionada = await showDatePicker(
                  context: context,
                  initialDate: hoy,
                  firstDate: hoy,
                  lastDate: DateTime(hoy.year + 1),
                  builder: (_, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
                      ),
                      child: child!,
                    );
                  },
                );

                if (seleccionada != null) {
                  await vm.seleccionarFecha(seleccionada, barberiaId);
                }
              },
            ),

            const SizedBox(height: 20),

            // ------------------ HORAS ------------------
            const Text("Hora:", style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),

            if (vm.fechaSeleccionada == null)
              const Text("Selecciona una fecha.", style: TextStyle(color: Colors.white54)),

            if (vm.cargandoHoras)
              const Center(child: CircularProgressIndicator(color: Colors.redAccent)),

            if (!vm.cargandoHoras && vm.fechaSeleccionada != null && vm.horasDisponibles.isEmpty)
              const Text("No hay horas disponibles.", style: TextStyle(color: Colors.redAccent)),

            if (!vm.cargandoHoras && vm.horasDisponibles.isNotEmpty)
              HorasDisponibles(
                horas: vm.horasDisponibles,
                seleccionada: vm.horaSeleccionada,
                onSelect: vm.seleccionarHora,
              ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(14)),
                icon: vm.guardando
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check, color: Colors.white),

                label: Text(
                  vm.guardando ? "Guardando..." : "Confirmar cita",
                  style: const TextStyle(color: Colors.white),
                ),

                onPressed: vm.guardando
                    ? null
                    : () async {
                  final error = await vm.crearCita(
                    barberiaId: barberiaId,
                    barberiaNombre: barberiaNombre,
                  );

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita reservada correctamente 🎉")));
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
