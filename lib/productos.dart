import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductosScreen extends StatelessWidget {
  const ProductosScreen({super.key});

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
            return const Center(
              child: Text(
                'No hay productos disponibles',
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

              childAspectRatio: .65,
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
                    // ===========================
                    // IMAGEN
                    // ===========================
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

                              size: 50,

                              color: Colors.purple,
                            ),
                          );
                        },
                      ),
                    ),

                    // ===========================
                    // INFORMACIÓN
                    // ===========================
                    Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            datos['nombre'] ?? 'Sin nombre',

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            datos['categoria'] ?? 'Sin categoría',

                            style: const TextStyle(
                              color: Colors.grey,

                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'MXN \$${datos['precio'] ?? 0}',

                            style: const TextStyle(
                              color: Colors.purple,

                              fontWeight: FontWeight.bold,

                              fontSize: 16,
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
