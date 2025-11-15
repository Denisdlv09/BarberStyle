import 'package:flutter/material.dart';

class ServicioDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> servicios;
  final String? valorSeleccionado;
  final Function(String?) onChanged;

  const ServicioDropdown({
    super.key,
    required this.servicios,
    required this.valorSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valorSeleccionado,
      dropdownColor: Colors.grey[900],
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(color: Colors.white),

      // CORRECCIÓN: especificar tipo en el map
      items: servicios.map<DropdownMenuItem<String>>((serv) {
        final nombre = serv["nombre"] as String;
        final precio = serv["precio"];

        return DropdownMenuItem<String>(
          value: nombre,
          child: Text("$nombre - €$precio"),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}
