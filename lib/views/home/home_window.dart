import 'package:flutter/material.dart';
import 'package:barberstyle/data/models/barberia_model.dart';
import 'package:barberstyle/data/services/barberia_service.dart';

class HomeWindow extends StatefulWidget {
  @override
  _HomeWindowState createState() => _HomeWindowState();
}

class _HomeWindowState extends State<HomeWindow> {
  final BarberiaService _barberiaService = BarberiaService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Barber Style',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // 🧾 TAB 1: Mostrar barberías desde Firebase
                  StreamBuilder<List<BarberiaModel>>(
                    stream: _barberiaService.obtenerBarberias(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "No hay barberías registradas aún.",
                            style: TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                        );
                      }

                      final barberias = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: barberias.length,
                        itemBuilder: (context, index) {
                          final b = barberias[index];
                          return _buildSalonCard(b);
                        },
                      );
                    },
                  ),

                  // 🏪 TAB 2: Añadir nueva barbería
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Añadir Tu Peluquería',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nombreController,
                          decoration: _inputDecoration('Nombre de la peluquería', Icons.business),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _direccionController,
                          decoration: _inputDecoration('Dirección', Icons.location_on),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _telefonoController,
                          decoration: _inputDecoration('Teléfono', Icons.phone),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _agregarBarberia,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            'Añadir Peluquería',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 📌 TabBar inferior
            Container(
              color: Colors.black,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Peluquerías Cerca'),
                  Tab(text: 'Añadir Peluquería'),
                ],
                indicatorColor: Colors.redAccent,
                labelColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _agregarBarberia() async {
    final nombre = _nombreController.text.trim();
    final direccion = _direccionController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (nombre.isEmpty || direccion.isEmpty || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    final nuevaBarberia = BarberiaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      direccion: direccion,
      telefono: telefono,
      descripcion: '',
      imagenUrl: '',
      valoracion: 0.0,
      servicios: [],
    );

    await _barberiaService.agregarBarberia(nuevaBarberia);

    _nombreController.clear();
    _direccionController.clear();
    _telefonoController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Barbería añadida correctamente")),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildSalonCard(BarberiaModel b) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (b.imagenUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  b.imagenUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.nombre,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(b.direccion, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('Tel: ${b.telefono}', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(b.valoracion.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
