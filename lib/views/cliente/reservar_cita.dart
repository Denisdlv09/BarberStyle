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
  String? _horaSeleccionada;
  bool _guardando = false;

  List<String> _horasDisponibles = [];
  List<String> _horasOcupadas = [];

  /// 🔹 Horario fijo de la barbería
  final List<String> _horasTotales = [
    "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30",
    "15:00", "15:30", "16:00", "16:30",
    "17:00", "17:30", "18:00", "18:30",
    "19:00", "19:30", "20:00", "20:30",
  ];

  /// 🔹 Cargar las horas ocupadas para la fecha seleccionada
  Future<void> _cargarHorasOcupadas() async {
    if (_fechaSeleccionada == null) return;

    final fechaStr = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);

    final snapshot = await FirebaseFirestore.instance
        .collection('barberias')
        .doc(widget.barberiaId)
        .collection('citas')
        .where('fechaStr', isEqualTo: fechaStr)
        .get();

    final ocupadas = snapshot.docs.map((doc) => doc['hora'] as String).toList();

    setState(() {
      _horasOcupadas = ocupadas;
      _horasDisponibles =
          _horasTotales.where((h) => !_horasOcupadas.contains(h)).toList();
      _horaSeleccionada = null;
    });
  }

  /// 🔹 Seleccionar fecha con calendario
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
      await _cargarHorasOcupadas();
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

      // 🔹 Formatear fecha y hora
      final fechaStr = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);
      final fechaHoraCita = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        int.parse(_horaSeleccionada!.split(':')[0]),
        int.parse(_horaSeleccionada!.split(':')[1]),
      );

      // 🔹 Verificar que la hora no esté ocupada
      final ocupadaSnapshot = await FirebaseFirestore.instance
          .collection('barberias')
          .doc(widget.barberiaId)
          .collection('citas')
          .where('fechaStr', isEqualTo: fechaStr)
          .where('hora', isEqualTo: _horaSeleccionada)
          .get();

      if (ocupadaSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Esa hora ya está ocupada ⛔")),
        );
        setState(() => _guardando = false);
        await _cargarHorasOcupadas();
        return;
      }

      // 🔹 Datos de la cita
      final citaData = {
        'clienteId': user.uid,
        'clienteNombre': clienteNombre,
        'barberiaId': widget.barberiaId,
        'barberiaNombre': widget.barberiaNombre,
        'servicio': _servicioSeleccionado,
        'fecha': Timestamp.fromDate(fechaHoraCita),
        'fechaStr': fechaStr, // campo auxiliar para búsquedas
        'hora': _horaSeleccionada,
        'estado': 'pendiente',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 🔹 Guardar la cita en barbería
      final citaRef = await FirebaseFirestore.instance
          .collection('barberias')
          .doc(widget.barberiaId)
          .collection('citas')
          .add(citaData);

      // 🔹 Guardar también en usuario
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selecciona un servicio:",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),

              // 🔹 Servicios desde Firestore
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
                style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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

              if (_fechaSeleccionada == null)
                const Text(
                  "Primero selecciona una fecha.",
                  style: TextStyle(color: Colors.white54),
                )
              else if (_horasDisponibles.isEmpty)
                const Text(
                  "No hay horas disponibles este día.",
                  style: TextStyle(color: Colors.redAccent),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _horasDisponibles.map((hora) {
                    final isSelected = _horaSeleccionada == hora;
                    return ChoiceChip(
                      label: Text(hora,
                          style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white)),
                      selected: isSelected,
                      selectedColor: Colors.redAccent,
                      backgroundColor: Colors.grey[850],
                      onSelected: (_) {
                        setState(() => _horaSeleccionada = hora);
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 40),
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
      ),
    );
  }
}
