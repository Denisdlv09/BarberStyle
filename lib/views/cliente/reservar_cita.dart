import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReservarCita extends StatefulWidget {
  final String barberiaId;
  final String barberiaNombre;

  const ReservarCita({
    super.key,
    required this.barberiaId,
    required this.barberiaNombre,
  });

  @override
  State<ReservarCita> createState() => _ReservarCitaState();
}

class _ReservarCitaState extends State<ReservarCita> {
  String? _servicioSeleccionado;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _guardando = false;

  /// 🔹 Seleccionar fecha
  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
        ),
        child: child!,
      ),
    );

    if (seleccionada != null) {
      setState(() => _fechaSeleccionada = seleccionada);
    }
  }

  /// 🔹 Seleccionar hora
  Future<void> _seleccionarHora() async {
    final seleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
        ),
        child: child!,
      ),
    );

    if (seleccionada != null) {
      setState(() => _horaSeleccionada = seleccionada);
    }
  }

  /// 🔹 Guardar cita en Firestore
  Future<void> _guardarCita() async {
    if (_servicioSeleccionado == null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      // 🔹 Obtener nombre del cliente
      String clienteNombre = user.displayName ?? '';

      // Si el displayName está vacío, buscar en la colección 'usuarios'
      if (clienteNombre.isEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        final data = userDoc.data();
        if (data != null && data.containsKey('nombre')) {
          clienteNombre = data['nombre'];
        } else if (data != null && data.containsKey('nombreCompleto')) {
          clienteNombre = data['nombreCompleto'];
        } else {
          clienteNombre = 'Cliente';
        }
      }

      // Combinar fecha y hora
      final fechaCita = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      // Datos de la cita
      final citaData = {
        'clienteId': user.uid,
        'clienteNombre': clienteNombre,
        'barberiaId': widget.barberiaId,
        'barberiaNombre': widget.barberiaNombre,
        'servicio': _servicioSeleccionado,
        'fecha': Timestamp.fromDate(fechaCita),
        'estado': 'pendiente',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 🔹 Guardar la cita dentro de la barbería
      final citaRef = await FirebaseFirestore.instance
          .collection('barberias')
          .doc(widget.barberiaId)
          .collection('citas')
          .add(citaData);

      // 🔹 Guardar también en el perfil del cliente
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('citas')
          .doc(citaRef.id)
          .set(citaData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cita reservada correctamente 🎉")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error al guardar cita: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al guardar la cita")),
      );
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Reservar cita en ${widget.barberiaNombre}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Selecciona un servicio:",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),

            // 🔹 Lista desplegable de servicios
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('barberias')
                  .doc(widget.barberiaId)
                  .collection('servicios')
                  .orderBy('nombre')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                final servicios = snapshot.data!.docs;
                if (servicios.isEmpty) {
                  return const Text(
                    "No hay servicios disponibles.",
                    style: TextStyle(color: Colors.white70),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _servicioSeleccionado,
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: servicios.map<DropdownMenuItem<String>>((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = (data['nombre'] ?? 'Sin nombre').toString();
                    final precio = data['precio']?.toString() ?? 'N/A';
                    return DropdownMenuItem<String>(
                      value: nombre,
                      child: Text("$nombre - \$${precio}"),
                    );
                  }).toList(),
                  onChanged: (valor) =>
                      setState(() => _servicioSeleccionado = valor),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text("Selecciona la fecha:",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: Text(
                _fechaSeleccionada != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)
                    : "Elegir fecha",
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: _seleccionarFecha,
            ),

            const SizedBox(height: 20),
            const Text("Selecciona la hora:",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.access_time, color: Colors.white),
              label: Text(
                _horaSeleccionada != null
                    ? _horaSeleccionada!.format(context)
                    : "Elegir hora",
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: _seleccionarHora,
            ),

            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Confirmar cita",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: _guardando ? null : _guardarCita,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
