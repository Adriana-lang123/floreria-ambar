import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'agregar_producto.dart';
import 'editar_producto.dart';

class ProductosAdminScreen extends StatelessWidget {
  const ProductosAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'Productos',

          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,

              color: Colors.purple,

              size: 30,
            ),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => AgregarProductoScreen()),
              );
            },
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay productos registrados',

                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final productos = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: productos.length,

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: .60,
            ),

            itemBuilder: (context, index) {
              final producto = productos[index];

              final datos = producto.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,

                shadowColor: Colors.purple.shade100,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                clipBehavior: Clip.antiAlias,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child: Image.network(
                        datos['imagenUrl'] ?? '',

                        width: double.infinity,

                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade100,

                            child: const Icon(
                              Icons.local_florist,

                              color: Colors.purple,

                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            datos['nombre'] ?? 'Sin nombre',

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            datos['categoria'] ?? '',

                            style: const TextStyle(
                              color: Colors.grey,

                              fontSize: 12,
                            ),
                          ),

                          Text(
                            'MXN \$${datos['precio'] ?? 0}',

                            style: const TextStyle(
                              color: Colors.purple,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.purple,
                                ),

                                onPressed: () {
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder: (_) => EditarProductoScreen(
                                        id: producto.id,

                                        producto: datos,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,

                                  color: Colors.red,
                                ),

                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('productos')
                                      .doc(producto.id)
                                      .delete();
                                },
                              ),
                            ],
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
