import 'package:flutter/material.dart';

class HorasDisponibles extends StatelessWidget {
  final List<String> horas;
  final String? seleccionada;
  final Function(String) onSelect;

  const HorasDisponibles({
    super.key,
    required this.horas,
    required this.seleccionada,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: horas.map((hora) {
        final isSelected = seleccionada == hora;
        return ChoiceChip(
          label: Text(
            hora,
            style: TextStyle(color: isSelected ? Colors.black : Colors.white),
          ),
          selected: isSelected,
          selectedColor: Colors.redAccent,
          backgroundColor: Colors.grey[850],
          onSelected: (_) => onSelect(hora),
        );
      }).toList(),
    );
  }
}
