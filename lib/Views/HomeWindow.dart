import 'package:flutter/material.dart';

class HomeWindow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Barber Style',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent, // Elimina el fondo negro
          elevation: 0, // Elimina la sombra
        ),
        body: Column(
          children: [
            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                children: [
                  // Primera pestaña: Peluquerías Cerca
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Buscador
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar peluquerías en tu zona...',
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Bloques de peluquerías inventadas
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildSalonCard('Peluquería Moderno', 'assets/images/salon1.png', 'Un lugar elegante y moderno para tu cuidado personal.'),
                              _buildSalonCard('Peluquería Glamour', 'assets/images/salon2.jpeg', 'Estilo y confort en cada corte.'),
                              _buildSalonCard('Barbería El Corte', 'assets/images/salon3.jpeg', 'Corte clásico y moderno, para todos los gustos.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Segunda pestaña: Añadir Peluquería
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añadir Tu Peluquería',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Nombre de la peluquería',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.business, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Dirección',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.location_on, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Teléfono',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.phone, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            // Lógica para guardar la peluquería
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                          child: Text(
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

            // TabBar en la parte inferior
            Container(
              color: Colors.black,
              child: TabBar(
                tabs: [
                  Tab(text: 'Peluquerías Cerca'),
                  Tab(text: 'Añadir Peluquería'),
                ],
                indicatorColor: Colors.redAccent, // Color del indicador
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para crear las tarjetas de las peluquerías
  Widget _buildSalonCard(String name, String imagePath, String description) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          // Acción al tocar la tarjeta
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
