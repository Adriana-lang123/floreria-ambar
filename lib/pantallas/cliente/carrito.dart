import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'carrito/carrito_provider.dart';
import 'pedido.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoProvider>(
      builder: (context, carrito, child) {
        return Scaffold(
          backgroundColor: const Color(0xffFFF8FC),

          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Mi carrito',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: carrito.productos.isEmpty
              ? _carritoVacio()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: carrito.productos.length,
                        itemBuilder: (context, index) {
                          final producto = carrito.productos[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(10),

                              child: Row(
                                children: [
                                  // IMAGEN
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),

                                    child: Image.network(
                                      producto['imagenUrl'] ?? '',

                                      width: 80,

                                      height: 80,

                                      fit: BoxFit.cover,

                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 80,

                                              height: 80,

                                              color: Colors.purple.shade50,

                                              child: const Icon(
                                                Icons.local_florist,

                                                color: Colors.purple,

                                                size: 35,
                                              ),
                                            );
                                          },
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // INFORMACIÓN
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          producto['nombre'],
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          'MXN \$${producto['precio']}',
                                          style: const TextStyle(
                                            color: Colors.purple,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ELIMINAR
                                  IconButton(
                                    onPressed: () {
                                      carrito.eliminarProducto(index);
                                    },

                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // TOTAL
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: const BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                'MXN \$${carrito.total.toStringAsFixed(2)}',

                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PedidoScreen(carrito: carrito),
                                  ),
                                );
                              },

                              child: const Text(
                                'HACER PEDIDO',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
  }

  Widget _carritoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.purple.shade200,
          ),

          const SizedBox(height: 15),

          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Agrega algunas flores para comenzar',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
