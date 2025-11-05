import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  int _rating = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _enviando = false;
  String? _resenaIdExistente;

  /// 🔹 Cargar reseña existente (si ya la dejó este usuario)
  Future<void> _cargarResenaExistente() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('barberias')
        .doc(widget.barberiaId)
        .collection('resenas')
        .where('clienteId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _resenaIdExistente = snapshot.docs.first.id;
        _rating = data['calificacion'] ?? 0;
        _comentarioController.text = data['comentario'] ?? '';
      });
    }
  }

  /// 🔹 Enviar o actualizar reseña
  Future<void> _enviarResena() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes iniciar sesión para dejar una reseña")),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una calificación antes de enviar")),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final resena = {
        'clienteId': user.uid,
        'nombreCliente': user.displayName ?? 'Cliente',
        'barberiaId': widget.barberiaId,
        'barberiaNombre': widget.barberiaNombre,
        'comentario': _comentarioController.text.trim(),
        'calificacion': _rating,
        'fecha': FieldValue.serverTimestamp(),
      };

      final barberiaRef = FirebaseFirestore.instance
          .collection('barberias')
          .doc(widget.barberiaId);

      final resenasRef = barberiaRef.collection('resenas');

      if (_resenaIdExistente != null) {
        await resenasRef.doc(_resenaIdExistente).update(resena);
      } else {
        await resenasRef.add(resena);
      }

      // 🔹 Actualizar promedio de calificaciones
      await _actualizarPromedio(barberiaRef);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Reseña enviada con éxito")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error al enviar reseña: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al enviar reseña: $e")),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  /// 🔹 Eliminar reseña existente
  Future<void> _eliminarResena() async {
    if (_resenaIdExistente == null) return;

    final barberiaRef =
    FirebaseFirestore.instance.collection('barberias').doc(widget.barberiaId);

    await barberiaRef.collection('resenas').doc(_resenaIdExistente).delete();
    await _actualizarPromedio(barberiaRef);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Reseña eliminada")),
    );

    Navigator.pop(context);
  }

  /// 🔹 Calcular y actualizar el promedio de calificaciones
  Future<void> _actualizarPromedio(DocumentReference barberiaRef) async {
    final snapshot = await barberiaRef.collection('resenas').get();
    if (snapshot.docs.isEmpty) {
      await barberiaRef.update({'ratingPromedio': 0});
      return;
    }

    double total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['calificacion'] ?? 0).toDouble();
    }

    final promedio = total / snapshot.docs.length;
    await barberiaRef.update({'ratingPromedio': promedio});
  }

  /// 🔹 Widget de estrellas
  Widget _buildEstrellas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final estrellaIndex = index + 1;
        return IconButton(
          onPressed: () => setState(() => _rating = estrellaIndex),
          icon: Icon(
            estrellaIndex <= _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarResenaExistente();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
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
            _buildEstrellas(),
            const SizedBox(height: 20),
            const Text(
              "Escribe un comentario:",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _comentarioController,
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
              onPressed: _enviando ? null : _enviarResena,
              icon: _enviando
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.send, color: Colors.white),
              label: Text(
                _enviando
                    ? "Enviando..."
                    : _resenaIdExistente != null
                    ? "Actualizar reseña"
                    : "Enviar reseña",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_resenaIdExistente != null) ...[
              const SizedBox(height: 15),
              TextButton.icon(
                onPressed: _eliminarResena,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                label: const Text(
                  "Eliminar reseña",
                  style: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
