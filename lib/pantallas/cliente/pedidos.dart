import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  Color colorEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return Colors.blue;

      case 'En preparación':
        return Colors.orange;

      case 'En camino':
        return Colors.indigo;

      case 'Entregado':
        return Colors.green;

      case 'Rechazado':
        return Colors.red;

      default:
        return Colors.amber.shade800;
    }
  }

  IconData iconoEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return Icons.check_circle_outline;

      case 'En preparación':
        return Icons.local_florist;

      case 'En camino':
        return Icons.local_shipping_outlined;

      case 'Entregado':
        return Icons.done_all;

      case 'Rechazado':
        return Icons.cancel_outlined;

      default:
        return Icons.hourglass_empty;
    }
  }

  String formatoFecha(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Sin fecha';
    }

    final fecha = timestamp.toDate();

    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Scaffold(body: Center(child: Text('Debes iniciar sesión')));
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Mis pedidos',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('usuarioId', isEqualTo: usuario.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Aún no tienes pedidos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Tus pedidos aparecerán aquí',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,

            itemBuilder: (context, index) {
              final pedido = pedidos[index].data() as Map<String, dynamic>;

              final estado = pedido['estado'] ?? 'Pendiente';

              final productos = pedido['productos'] as List? ?? [];

              final fechaEntrega = pedido['fechaEntrega'] as Timestamp?;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),

                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // -----------------------------
                      // ESTADO
                      // -----------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            'Pedido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),

                            decoration: BoxDecoration(
                              color: colorEstado(estado).withOpacity(0.12),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  iconoEstado(estado),

                                  size: 17,

                                  color: colorEstado(estado),
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  estado,

                                  style: TextStyle(
                                    color: colorEstado(estado),

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      // -----------------------------
                      // PRODUCTOS
                      // -----------------------------
                      const Text(
                        'Productos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      ...productos.map((producto) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_florist,
                                size: 18,
                                color: Colors.purple,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(producto['nombre'] ?? 'Producto'),
                              ),

                              Text(
                                'MXN \$${producto['precio'] ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // -----------------------------
                      // TOTAL
                      // -----------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'MXN \$${(pedido['total'] ?? 0).toStringAsFixed(2)}',

                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      // -----------------------------
                      // DIRECCIÓN
                      // -----------------------------
                      const Text(
                        'Entrega',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.purple,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(pedido['direccion'] ?? 'Sin dirección'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // -----------------------------
                      // FECHA Y HORA
                      // -----------------------------
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.purple,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            fechaEntrega != null
                                ? formatoFecha(fechaEntrega)
                                : pedido['fechaEntregaTexto'] ?? 'Sin fecha',
                          ),

                          const SizedBox(width: 20),

                          const Icon(
                            Icons.access_time,
                            size: 20,
                            color: Colors.purple,
                          ),

                          const SizedBox(width: 8),

                          Text(pedido['horaEntrega'] ?? 'Sin hora'),
                        ],
                      ),

                      if ((pedido['referencia'] ?? '')
                          .toString()
                          .isNotEmpty) ...[
                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.purple,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                'Referencia: ${pedido['referencia']}',
                              ),
                            ),
                          ],
                        ),
                      ],
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
