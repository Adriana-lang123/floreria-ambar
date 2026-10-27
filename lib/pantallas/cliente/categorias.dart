import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'carrito/carrito_provider.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'Categorías',

          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos')
            .where('disponible', isEqualTo: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay categorías disponibles'));
          }

          final productos = snapshot.data!.docs;

          Map<String, dynamic> categorias = {};

          for (var producto in productos) {
            final datos = producto.data() as Map<String, dynamic>;

            categorias[datos['categoria']] = datos;
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: categorias.keys.length,

            itemBuilder: (context, index) {
              String nombreCategoria = categorias.keys.elementAt(index);

              final producto = categorias[nombreCategoria];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          ProductosCategoriaScreen(categoria: nombreCategoria),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),

                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(25),

                    boxShadow: [
                      BoxShadow(color: Colors.purple.shade100, blurRadius: 8),
                    ],
                  ),

                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          producto['imagenUrl'],

                          width: 75,

                          height: 75,

                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Text(
                        nombreCategoria,

                        style: const TextStyle(
                          fontSize: 20,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      const Icon(Icons.arrow_forward_ios, color: Colors.purple),
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

class ProductosCategoriaScreen extends StatelessWidget {
  final String categoria;

  const ProductosCategoriaScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: Text(
          categoria,

          style: const TextStyle(
            color: Colors.black87,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos')
            .where('categoria', isEqualTo: categoria)
            .where('disponible', isEqualTo: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: productos.length,

            itemBuilder: (context, index) {
              final datos = productos[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 5,

                margin: const EdgeInsets.only(bottom: 20),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),

                clipBehavior: Clip.antiAlias,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Image.network(
                      datos['imagenUrl'],

                      height: 230,

                      width: double.infinity,

                      fit: BoxFit.cover,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            datos['nombre'],

                            style: const TextStyle(
                              fontSize: 22,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            datos['descripcion'] ?? 'Sin descripción',

                            style: const TextStyle(
                              color: Colors.grey,

                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'MXN \$${datos['precio']}',

                            style: const TextStyle(
                              color: Colors.purple,

                              fontSize: 20,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,

                            height: 50,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,

                                foregroundColor: Colors.white,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),

                              onPressed: () {
                                context
                                    .read<CarritoProvider>()
                                    .agregarProducto({
                                      'nombre': datos['nombre'],

                                      'precio': datos['precio'],

                                      'imagenUrl': datos['imagenUrl'],

                                      'categoria': datos['categoria'],
                                    });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${datos['nombre']} agregado',
                                    ),
                                  ),
                                );
                              },

                              child: const Text('Agregar al carrito'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
