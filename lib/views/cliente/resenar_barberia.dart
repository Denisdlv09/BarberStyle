import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/resenas_viewmodel.dart';

class ResenarBarberia extends StatefulWidget {
  final String barberiaId;
  final String barberiaNombre;

  const ResenarBarberia({
    super.key,
    required this.barberiaId,
    required this.barberiaNombre,
  });

  @override
  State<ResenarBarberia> createState() => _ResenarBarberiaState();
}

class _ResenarBarberiaState extends State<ResenarBarberia> {
  final TextEditingController _comentarioCtrl = TextEditingController();
  double _rating = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ResenasViewModel>();
      await vm.cargarResena(widget.barberiaId);

      if (vm.reviewActual != null) {
        _rating = vm.reviewActual!.puntuacion;
        _comentarioCtrl.text = vm.reviewActual!.comentario;
      }
    });
  }

  Widget _estrellas(double value, ValueChanged<double> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final index = i + 1;
        return IconButton(
          onPressed: () => onChanged(index.toDouble()),
          icon: Icon(
            index <= value ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResenasViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              "Reseñar ${widget.barberiaNombre}",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: vm.isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          )
              : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Califica tu experiencia:",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _estrellas(_rating, (val) {
                  setState(() => _rating = val);
                }),

                const SizedBox(height: 20),
                const Text(
                  "Escribe un comentario:",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _comentarioCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "¿Qué te pareció la barbería?",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                    await vm.guardarResena(
                      barberiaId: widget.barberiaId,
                      puntuacion: _rating,
                      comentario: _comentarioCtrl.text.trim(),
                    );

                    if (context.mounted && vm.errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Reseña guardada correctamente 🎉"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: vm.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    vm.reviewActual == null
                        ? "Enviar reseña"
                        : "Actualizar reseña",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (vm.reviewActual != null) ...[
                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: () async {
                      await vm.eliminarResena(widget.barberiaId);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Reseña eliminada 🗑️"),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    label: const Text(
                      "Eliminar reseña",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
