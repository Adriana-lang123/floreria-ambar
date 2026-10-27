import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../estado/carrito_provider.dart';
import 'categorias.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'Florería Ámbar',

          style: TextStyle(
            color: Colors.black87,

            fontSize: 25,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==========================
            // BANNER
            // ==========================
            Container(
              width: double.infinity,

              height: 190,

              margin: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                image: const DecorationImage(
                  image: AssetImage('assets/imagenes/banner_flores.jpg'),

                  fit: BoxFit.cover,
                ),
              ),

              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),

                  color: Colors.black26,
                ),

                padding: const EdgeInsets.all(20),

                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Flores que crean\nmomentos especiales 🌸',

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 23,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Encuentra el arreglo perfecto',

                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================
            // CATEGORIAS
            // ==========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(builder: (_) => const CategoriasScreen()),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: [
                      BoxShadow(color: Colors.purple.shade100, blurRadius: 8),
                    ],
                  ),

                  child: const Row(
                    children: [
                      Icon(Icons.category, color: Colors.purple, size: 30),

                      SizedBox(width: 15),

                      Text(
                        'Ver categorías',

                        style: TextStyle(
                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Spacer(),

                      Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                'Productos destacados',

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // ==========================
            // PRODUCTOS FIREBASE
            // ==========================
            StreamBuilder<QuerySnapshot>(
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
                    child: Text('No hay productos disponibles'),
                  );
                }

                final productos = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  padding: const EdgeInsets.all(16),

                  itemCount: productos.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 15,

                    mainAxisSpacing: 15,

                    childAspectRatio: .62,
                  ),

                  itemBuilder: (context, index) {
                    final datos =
                        productos[index].data() as Map<String, dynamic>;

                    return productoCard(context, datos);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget productoCard(
    BuildContext context,

    Map<String, dynamic> producto,
  ) {
    return Card(
      elevation: 5,

      shadowColor: Colors.purple.shade100,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [
          Expanded(
            child: Image.network(
              producto['imagenUrl'] ?? '',

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

          Padding(
            padding: const EdgeInsets.all(10),

            child: Column(
              children: [
                Text(
                  producto['nombre'] ?? '',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  'MXN \$${producto['precio']}',

                  style: const TextStyle(
                    color: Colors.purple,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    onPressed: () {
                      context.read<CarritoProvider>().agregarProducto({
                        'nombre': producto['nombre'],

                        'precio': producto['precio'],

                        'imagenUrl': producto['imagenUrl'],

                        'categoria': producto['categoria'],
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${producto['nombre']} agregado'),
                        ),
                      );
                    },

                    child: const Text('Agregar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
