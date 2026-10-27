import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  String estadoSeleccionado = 'Todos';

  final List<String> estados = [
    'Todos',
    'Pendiente',
    'Preparando',
    'Listo para entregar',
    'En camino',
    'Entregado',
    'No entregado',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Pedidos',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Ocurrió un error al cargar los pedidos.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay pedidos registrados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final todosLosPedidos = snapshot.data!.docs;

          final pedidos = estadoSeleccionado == 'Todos'
              ? todosLosPedidos
              : todosLosPedidos.where((pedido) {
                  final datos = pedido.data() as Map<String, dynamic>;

                  final estado = (datos['estado'] ?? 'Pendiente').toString();

                  return estado == estadoSeleccionado;
                }).toList();

          return Column(
            children: [
              // =================================================
              // FILTRO POR ESTADO
              // =================================================
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por estado',
                    prefixIcon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: const Color(0xffFAF7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Colors.purple,
                        width: 1.3,
                      ),
                    ),
                  ),
                  items: estados.map((estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: (nuevoEstado) {
                    if (nuevoEstado == null) {
                      return;
                    }

                    setState(() {
                      estadoSeleccionado = nuevoEstado;
                    });
                  },
                ),
              ),

              // =================================================
              // CONTADOR
              // =================================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${pedidos.length} ${pedidos.length == 1 ? 'pedido' : 'pedidos'}',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // =================================================
              // LISTA
              // =================================================
              Expanded(
                child: pedidos.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 55,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No hay pedidos con este estado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];

                          final datos = pedido.data() as Map<String, dynamic>;

                          final nombreCliente =
                              datos['nombreCliente'] ?? 'Cliente';

                          final correoCliente = datos['correoCliente'] ?? '';

                          final telefonoCliente =
                              datos['telefonoCliente'] ?? '';

                          final direccion = datos['direccion'] ?? '';

                          final referencia = datos['referencia'] ?? '';

                          final fechaEntrega =
                              datos['fechaEntregaTexto'] ?? 'Sin fecha';

                          final horaEntrega =
                              datos['horaEntrega'] ?? 'Sin hora';

                          final estado = datos['estado'] ?? 'Pendiente';

                          final motivoNoEntrega =
                              datos['motivoNoEntrega'] ?? '';

                          final total =
                              (datos['total'] as num?)?.toDouble() ?? 0;

                          final productos =
                              datos['productos'] as List<dynamic>? ?? [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            elevation: 3,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  12,
                                  12,
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  18,
                                ),
                                iconColor: Colors.purple,
                                collapsedIconColor: Colors.grey,

                                // ==========================================
                                // RESUMEN
                                // ==========================================
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.purple,
                                  ),
                                ),

                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Pedido #${pedido.id.substring(0, 6).toUpperCase()}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        _estadoChip(estado.toString()),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      nombreCliente.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            fechaEntrega.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              horaEntrega.toString(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 7),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.payments_outlined,
                                            size: 17,
                                            color: Colors.purple,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'MXN \$${total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 7),

                                      const Text(
                                        'Toca para ver detalles',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ==========================================
                                // DETALLES
                                // ==========================================
                                children: [
                                  const Divider(),

                                  const SizedBox(height: 10),

                                  // ========================================
                                  // CLIENTE
                                  // ========================================
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Cliente',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffFAF5FC),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      children: [
                                        _datoCliente(
                                          Icons.person_outline,
                                          nombreCliente.toString(),
                                        ),

                                        if (correoCliente.toString().isNotEmpty)
                                          _datoCliente(
                                            Icons.email_outlined,
                                            correoCliente.toString(),
                                          ),

                                        if (telefonoCliente
                                            .toString()
                                            .isNotEmpty)
                                          _datoCliente(
                                            Icons.phone_outlined,
                                            telefonoCliente.toString(),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ========================================
                                  // ENTREGA
                                  // ========================================
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Datos de entrega',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  _datoEntrega(
                                    Icons.location_on_outlined,
                                    'Dirección',
                                    direccion.toString(),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _datoEntrega(
                                          Icons.calendar_today_outlined,
                                          'Fecha',
                                          fechaEntrega.toString(),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: _datoEntrega(
                                          Icons.access_time,
                                          'Hora',
                                          horaEntrega.toString(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (referencia
                                      .toString()
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),

                                    _datoEntrega(
                                      Icons.info_outline,
                                      'Referencia',
                                      referencia.toString(),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  // ========================================
                                  // PRODUCTOS
                                  // ========================================
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Productos',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  if (productos.isEmpty)
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'No hay productos registrados',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),

                                  ...productos.map((producto) {
                                    final item = Map<String, dynamic>.from(
                                      producto,
                                    );

                                    final nombre = item['nombre'] ?? 'Producto';

                                    final precio =
                                        (item['precio'] as num?)?.toDouble() ??
                                        0;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.local_florist_outlined,
                                            color: Colors.purple,
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Text(nombre.toString()),
                                          ),

                                          Text(
                                            'MXN \$${precio.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  const Divider(height: 25),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        'MXN \$${total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // ========================================
                                  // ESTADO
                                  // ========================================
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Estado del pedido',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  if (estado == 'Pendiente' ||
                                      estado == 'Preparando' ||
                                      estado == 'Listo para entregar')
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: estado.toString(),
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'Pendiente',
                                              child: Text('Pendiente'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Preparando',
                                              child: Text('Preparando'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Listo para entregar',
                                              child: Text(
                                                'Listo para entregar',
                                              ),
                                            ),
                                          ],
                                          onChanged: (nuevoEstado) async {
                                            if (nuevoEstado == null) {
                                              return;
                                            }

                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('pedidos')
                                                  .doc(pedido.id)
                                                  .update({
                                                    'estado': nuevoEstado,
                                                  });

                                              if (!context.mounted) {
                                                return;
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Estado actualizado a $nuevoEstado',
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              if (!context.mounted) {
                                                return;
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'No se pudo actualizar el estado: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            estado == 'Entregado'
                                                ? Icons.check_circle_outline
                                                : estado == 'No entregado'
                                                ? Icons.cancel_outlined
                                                : Icons
                                                      .delivery_dining_outlined,
                                            color: estado == 'Entregado'
                                                ? Colors.green
                                                : estado == 'No entregado'
                                                ? Colors.red
                                                : Colors.orange,
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  estado.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const Text(
                                                  'Actualizado por repartidor',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const Icon(
                                            Icons.lock_outline,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),

                                  // ========================================
                                  // MOTIVO NO ENTREGA
                                  // ========================================
                                  if (estado == 'No entregado' &&
                                      motivoNoEntrega
                                          .toString()
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 12),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.20),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Motivo de no entrega',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(motivoNoEntrega.toString()),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // ========================================
                                  // REINTENTAR ENTREGA
                                  // ========================================
                                  if (estado == 'No entregado') ...[
                                    const SizedBox(height: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('pedidos')
                                                .doc(pedido.id)
                                                .update({
                                                  'estado':
                                                      'Listo para entregar',
                                                  'motivoNoEntrega':
                                                      FieldValue.delete(),
                                                });

                                            if (!context.mounted) {
                                              return;
                                            }

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Pedido enviado nuevamente a reparto',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            if (!context.mounted) {
                                              return;
                                            }

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'No se pudo reintentar la entrega: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.replay),
                                        label: const Text(
                                          'VOLVER A INTENTAR ENTREGA',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 15),

                                  // ========================================
                                  // ELIMINAR
                                  // ========================================
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        _confirmarEliminarPedido(
                                          context,
                                          pedido.id,
                                        );
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Eliminar pedido'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // ELIMINAR PEDIDO
  // =========================================================

  Future<void> _confirmarEliminarPedido(
    BuildContext context,
    String pedidoId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Eliminar pedido'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este pedido?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido eliminado correctamente')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el pedido: $e')),
      );
    }
  }

  // =========================================================
  // CHIP ESTADO
  // =========================================================

  static Widget _estadoChip(String estado) {
    Color color;

    switch (estado) {
      case 'Preparando':
        color = Colors.orange;
        break;

      case 'Listo para entregar':
        color = Colors.green;
        break;

      case 'En camino':
        color = Colors.deepOrange;
        break;

      case 'Entregado':
        color = Colors.green;
        break;

      case 'No entregado':
        color = Colors.red;
        break;

      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================================================
  // DATOS CLIENTE
  // =========================================================

  static Widget _datoCliente(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, color: Colors.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }

  // =========================================================
  // DATOS ENTREGA
  // =========================================================

  static Widget _datoEntrega(IconData icono, String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.purple, size: 20),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),

                const SizedBox(height: 2),

                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
