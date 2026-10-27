import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login.dart';
import 'perfil_repartidor.dart';

class HomeRepartidor extends StatelessWidget {
  const HomeRepartidor({super.key});

  // =====================================================
  // CERRAR SESIÓN
  // =====================================================

  Future<void> cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // =====================================================
  // CAMBIAR ESTADO
  // =====================================================

  Future<void> cambiarEstado(String pedidoId, String nuevoEstado) async {
    await FirebaseFirestore.instance.collection('pedidos').doc(pedidoId).update(
      {'estado': nuevoEstado},
    );
  }

  // =====================================================
  // NO ENTREGADO
  // =====================================================

  Future<void> mostrarMotivoNoEntrega(
    BuildContext context,
    String pedidoId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    // Aquí NO usamos TextEditingController.
    // Esto evita problemas al destruir el diálogo.
    String motivoEscrito = '';

    final String? motivo = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        String? errorTexto;

        return StatefulBuilder(
          builder: (contextDialogo, setStateDialogo) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(child: Text('No se pudo entregar')),
                ],
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escribe el motivo por el cual no fue posible realizar la entrega.',
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    maxLines: 3,

                    autofocus: true,

                    onChanged: (texto) {
                      motivoEscrito = texto;

                      if (errorTexto != null) {
                        setStateDialogo(() {
                          errorTexto = null;
                        });
                      }
                    },

                    decoration: InputDecoration(
                      hintText:
                          'Ej. El cliente no se encontraba en el domicilio',

                      errorText: errorTexto,

                      filled: true,

                      fillColor: const Color(0xffFAF7FA),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.purple,
                          width: 1.5,
                        ),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red),
                      ),

                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  child: const Text('Cancelar'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () {
                    final texto = motivoEscrito.trim();

                    if (texto.isEmpty) {
                      setStateDialogo(() {
                        errorTexto = 'Escribe el motivo de la no entrega';
                      });

                      return;
                    }

                    if (texto.length < 5) {
                      setStateDialogo(() {
                        errorTexto = 'Escribe un motivo más claro';
                      });

                      return;
                    }

                    // IMPORTANTE:
                    // Aquí NO actualizamos Firebase.
                    // Solamente cerramos el diálogo.

                    Navigator.of(dialogContext, rootNavigator: true).pop(texto);
                  },

                  child: const Text(
                    'GUARDAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Si presionó cancelar
    if (motivo == null || motivo.trim().isEmpty) {
      return;
    }

    // =====================================================
    // ESPERAMOS A QUE EL DIÁLOGO TERMINE DE CERRARSE
    // =====================================================

    await Future.delayed(const Duration(milliseconds: 400));

    // =====================================================
    // AHORA SÍ ACTUALIZAMOS FIREBASE
    // =====================================================

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .update({
            'estado': 'No entregado',
            'motivoNoEntrega': motivo.trim(),
            'fechaNoEntrega': FieldValue.serverTimestamp(),
          });

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Pedido marcado como no entregado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el motivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      // =================================================
      // APP BAR
      // =================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Mis entregas',
          style: TextStyle(
            color: Color(0xff2D1B33),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          // PERFIL
          IconButton(
            tooltip: 'Mi perfil',

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerfilRepartidorScreen(),
                ),
              );
            },

            icon: Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.10),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.person_outline,
                color: Colors.purple,
                size: 22,
              ),
            ),
          ),

          // CERRAR SESIÓN
          IconButton(
            tooltip: 'Cerrar sesión',

            onPressed: () {
              cerrarSesion(context);
            },

            icon: const Icon(Icons.logout_outlined, color: Colors.grey),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // =================================================
      // PEDIDOS
      // =================================================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('estado', whereIn: ['Listo para entregar', 'En camino'])
            .snapshots(),

        builder: (context, snapshot) {
          // =============================================
          // CARGANDO
          // =============================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          // =============================================
          // ERROR
          // =============================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 65,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'No se pudieron cargar las entregas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          // =============================================
          // SIN ENTREGAS
          // =============================================

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.delivery_dining_outlined,
                      size: 90,
                      color: Colors.purple,
                    ),

                    SizedBox(height: 18),

                    Text(
                      'No hay entregas pendientes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Los pedidos listos para entregar aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: pedidos.length,

            itemBuilder: (itemContext, index) {
              final documento = pedidos[index];

              final datos = documento.data() as Map<String, dynamic>;

              final String estado = datos['estado'] ?? '';

              final String nombre = datos['nombreCliente'] ?? 'Cliente';

              final String telefono =
                  datos['telefonoCliente'] ?? 'Sin teléfono';

              final String direccion =
                  datos['direccion'] ?? 'Sin dirección registrada';

              final String referencia = datos['referencia'] ?? 'Sin referencia';

              final String fecha = datos['fechaEntregaTexto'] ?? '';

              final String hora = datos['horaEntrega'] ?? '';

              // ===========================================
              // TARJETA
              // ===========================================

              return Container(
                key: ValueKey(documento.id),

                margin: const EdgeInsets.only(bottom: 18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),

                      blurRadius: 12,

                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ===================================
                      // CLIENTE Y ESTADO
                      // ===================================
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,

                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.10),

                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: Colors.purple,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  nombre,

                                  style: const TextStyle(
                                    fontSize: 18,

                                    fontWeight: FontWeight.bold,

                                    color: Color(0xff2D1B33),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: estado == 'En camino'
                                        ? Colors.orange.withOpacity(0.10)
                                        : Colors.green.withOpacity(0.10),

                                    borderRadius: BorderRadius.circular(15),
                                  ),

                                  child: Text(
                                    estado,

                                    style: TextStyle(
                                      color: estado == 'En camino'
                                          ? Colors.orange
                                          : Colors.green,

                                      fontSize: 12,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 30),

                      // ===================================
                      // DIRECCIÓN
                      // ===================================
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.purple,
                            size: 20,
                          ),

                          SizedBox(width: 7),

                          Text(
                            'Dirección de entrega',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Text(
                        direccion,

                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),

                      const SizedBox(height: 18),

                      // ===================================
                      // REFERENCIA
                      // ===================================
                      const Row(
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            color: Colors.purple,
                            size: 20,
                          ),

                          SizedBox(width: 7),

                          Text(
                            'Referencia',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: const Color(0xffFAF7FA),

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Text(
                          referencia,

                          style: const TextStyle(height: 1.4),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ===================================
                      // TELÉFONO
                      // ===================================
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: Colors.purple,
                            size: 20,
                          ),

                          const SizedBox(width: 7),

                          const Text(
                            'Teléfono: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Expanded(child: Text(telefono)),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ===================================
                      // FECHA Y HORA
                      // ===================================
                      Container(
                        padding: const EdgeInsets.all(13),

                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.06),

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.purple,
                              size: 18,
                            ),

                            const SizedBox(width: 7),

                            Expanded(
                              child: Text(
                                fecha.isEmpty ? 'Sin fecha' : fecha,

                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.access_time,
                              color: Colors.purple,
                              size: 18,
                            ),

                            const SizedBox(width: 7),

                            Text(
                              hora.isEmpty ? 'Sin hora' : hora,

                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===================================
                      // LISTO PARA ENTREGAR
                      // ===================================
                      if (estado == 'Listo para entregar')
                        SizedBox(
                          width: double.infinity,

                          height: 50,

                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,

                              foregroundColor: Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);

                              try {
                                await cambiarEstado(documento.id, 'En camino');

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Entrega iniciada'),
                                  ),
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'No se pudo iniciar la entrega: $e',
                                    ),
                                  ),
                                );
                              }
                            },

                            icon: const Icon(Icons.delivery_dining),

                            label: const Text(
                              'INICIAR ENTREGA',

                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      // ===================================
                      // EN CAMINO
                      // ===================================
                      if (estado == 'En camino') ...[
                        Row(
                          children: [
                            // =============================
                            // ENTREGADO
                            // =============================
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,

                                  foregroundColor: Colors.white,

                                  minimumSize: const Size(double.infinity, 50),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),

                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  try {
                                    await cambiarEstado(
                                      documento.id,
                                      'Entregado',
                                    );

                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pedido entregado correctamente',
                                        ),

                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo actualizar el pedido: $e',
                                        ),

                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },

                                icon: const Icon(Icons.check_circle),

                                label: const Text(
                                  'ENTREGADO',

                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // =============================
                            // NO ENTREGADO
                            // =============================
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,

                                  foregroundColor: Colors.white,

                                  minimumSize: const Size(double.infinity, 50),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),

                                onPressed: () {
                                  mostrarMotivoNoEntrega(context, documento.id);
                                },

                                icon: const Icon(Icons.cancel_outlined),

                                label: const Text(
                                  'NO ENTREGADO',

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,

                                    fontSize: 12,
                                  ),
                                ),
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
