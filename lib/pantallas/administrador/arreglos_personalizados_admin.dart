import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArreglosPersonalizadosAdminScreen extends StatelessWidget {
  const ArreglosPersonalizadosAdminScreen({super.key});

  // =====================================================
  // COLOR DEL ESTADO
  // =====================================================

  Color colorEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return Colors.green;

      case 'Rechazado':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // =====================================================
  // ICONO DEL ESTADO
  // =====================================================

  IconData iconoEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return Icons.check_circle_outline;

      case 'Rechazado':
        return Icons.cancel_outlined;

      default:
        return Icons.pending_outlined;
    }
  }

  // =====================================================
  // CAMBIAR ESTADO
  // =====================================================

  Future<void> cambiarEstado(
    BuildContext context,
    String id,
    String nuevoEstado,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('arreglos_personalizados')
          .doc(id)
          .update({'estado': nuevoEstado});

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevoEstado == 'Aceptado'
                ? 'Solicitud aceptada correctamente'
                : 'Solicitud rechazada correctamente',
          ),
          backgroundColor: nuevoEstado == 'Aceptado'
              ? Colors.green
              : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la solicitud: $e')),
      );
    }
  }

  // =====================================================
  // FORMATEAR FECHA
  // =====================================================

  String obtenerFecha(dynamic fecha) {
    if (fecha == null) {
      return 'No especificada';
    }

    if (fecha is Timestamp) {
      final DateTime fechaDate = fecha.toDate();

      return '${fechaDate.day.toString().padLeft(2, '0')}/'
          '${fechaDate.month.toString().padLeft(2, '0')}/'
          '${fechaDate.year}';
    }

    return 'No especificada';
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Arreglos personalizados',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('arreglos_personalizados')
            .orderBy('fechaSolicitud', descending: true)
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'No se pudieron cargar las solicitudes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_florist_outlined,
                      size: 75,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 15),

                    Text(
                      'No hay solicitudes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Las solicitudes de arreglos personalizados aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final solicitudes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: solicitudes.length,

            itemBuilder: (context, index) {
              final solicitud = solicitudes[index];

              final datos = solicitud.data() as Map<String, dynamic>;

              final String tipoArreglo =
                  datos['tipoArreglo'] ?? 'No especificado';

              final String estilo = datos['estilo'] ?? 'No especificado';

              final String tamano = datos['tamano'] ?? 'No especificado';

              final String ocasion = datos['ocasion'] ?? 'No especificada';

              final String colores = datos['colores'] ?? 'No especificados';

              final String presupuesto =
                  datos['presupuesto']?.toString() ?? 'No especificado';

              final String floresDeseadas = datos['floresDeseadas'] ?? '';

              final String floresNoDeseadas = datos['floresNoDeseadas'] ?? '';

              final String mensajeTarjeta = datos['mensajeTarjeta'] ?? '';

              final String descripcion = datos['descripcion'] ?? '';

              final bool permiteSustitucion =
                  datos['permiteSustitucion'] ?? false;

              final String estado = datos['estado'] ?? 'Pendiente';

              final String hora = datos['horaEntrega'] ?? 'No especificada';

              final String fecha = obtenerFecha(datos['fechaEntrega']);

              final String correo = datos['correoUsuario'] ?? 'Sin correo';

              final bool floristaEligeFlores =
                  datos['floristaEligeFlores'] ?? false;

              final Color estadoColor = colorEstado(estado);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                color: Colors.white,
                shadowColor: Colors.purple.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.fromLTRB(18, 14, 14, 14),

                    childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),

                    iconColor: Colors.purple,

                    collapsedIconColor: Colors.grey,

                    // =================================================
                    // RESUMEN
                    // =================================================
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_florist_outlined,
                        color: Colors.purple,
                        size: 27,
                      ),
                    ),

                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tipoArreglo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconoEstado(estado),
                                size: 15,
                                color: estadoColor,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                estado,
                                style: TextStyle(
                                  color: estadoColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  correo,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                fecha,
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
                                  hora,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 16,
                                color: Colors.purple,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                presupuesto.trim().isEmpty
                                    ? 'Presupuesto no especificado'
                                    : '\$$presupuesto MXN',
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Toca para ver detalles',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // DETALLES DESPLEGABLES
                    // =================================================
                    children: [
                      const Divider(),

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Detalles de la solicitud',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      _dato(
                        icono: Icons.local_florist_outlined,
                        titulo: 'Tipo de arreglo',
                        valor: tipoArreglo,
                      ),

                      const SizedBox(height: 12),

                      _dato(
                        icono: Icons.auto_awesome_outlined,
                        titulo: 'Estilo',
                        valor: estilo,
                      ),

                      const SizedBox(height: 12),

                      _dato(
                        icono: Icons.palette_outlined,
                        titulo: 'Colores predominantes',
                        valor: colores,
                      ),

                      const SizedBox(height: 12),

                      _dato(
                        icono: Icons.aspect_ratio,
                        titulo: 'Tamaño',
                        valor: tamano,
                      ),

                      const SizedBox(height: 12),

                      _dato(
                        icono: Icons.card_giftcard_outlined,
                        titulo: 'Ocasión',
                        valor: ocasion,
                      ),

                      const SizedBox(height: 12),

                      _dato(
                        icono: Icons.payments_outlined,
                        titulo: 'Presupuesto',
                        valor: presupuesto.trim().isEmpty
                            ? 'No especificado'
                            : '\$$presupuesto MXN',
                      ),

                      const SizedBox(height: 20),

                      const Divider(),

                      const SizedBox(height: 15),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Preferencias del cliente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _detalleTexto(
                        titulo: 'Flores que le gustaría incluir',
                        valor: floresDeseadas,
                        textoVacio: floristaEligeFlores
                            ? 'A elección de la florista'
                            : 'No especificadas',
                        icono: Icons.local_florist,
                      ),

                      const SizedBox(height: 10),

                      _detalleTexto(
                        titulo: 'Flores que no quiere',
                        valor: floresNoDeseadas,
                        textoVacio: 'Ninguna especificada',
                        icono: Icons.block_outlined,
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: permiteSustitucion
                              ? Colors.green.withOpacity(0.06)
                              : Colors.orange.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              permiteSustitucion
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              color: permiteSustitucion
                                  ? Colors.green
                                  : Colors.orange,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                permiteSustitucion
                                    ? 'Sí permite sustituir flores si alguna no está disponible.'
                                    : 'No permite sustituciones. Se debe contactar al cliente si alguna flor no está disponible.',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _detalleTexto(
                        titulo: 'Cómo imagina su arreglo',
                        valor: descripcion,
                        textoVacio: 'Sin descripción adicional',
                        icono: Icons.edit_note_outlined,
                      ),

                      const SizedBox(height: 10),

                      _detalleTexto(
                        titulo: 'Mensaje para tarjeta',
                        valor: mensajeTarjeta,
                        textoVacio: 'Sin mensaje para tarjeta',
                        icono: Icons.mail_outline,
                      ),

                      const SizedBox(height: 20),

                      const Divider(),

                      const SizedBox(height: 15),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Entrega',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _dato(
                              icono: Icons.calendar_today_outlined,
                              titulo: 'Fecha',
                              valor: fecha,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _dato(
                              icono: Icons.access_time,
                              titulo: 'Hora',
                              valor: hora,
                            ),
                          ),
                        ],
                      ),

                      // =================================================
                      // BOTONES
                      // =================================================
                      if (estado == 'Pendiente') ...[
                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  cambiarEstado(
                                    context,
                                    solicitud.id,
                                    'Rechazado',
                                  );
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Rechazar'),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 50),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  cambiarEstado(
                                    context,
                                    solicitud.id,
                                    'Aceptado',
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Aceptar'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // =================================================
                      // ESTADO FINAL
                      // =================================================
                      if (estado != 'Pendiente') ...[
                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: estadoColor.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            children: [
                              Icon(iconoEstado(estado), color: estadoColor),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  estado == 'Aceptado'
                                      ? 'Esta solicitud fue aceptada.'
                                      : 'Esta solicitud fue rechazada.',
                                  style: TextStyle(
                                    color: estadoColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  // =====================================================
  // DATO SIMPLE
  // =====================================================

  static Widget _dato({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: Colors.purple, size: 21),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 2),

              Text(
                valor,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BLOQUE DE TEXTO
  // =====================================================

  static Widget _detalleTexto({
    required String titulo,
    required String valor,
    required String textoVacio,
    required IconData icono,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffFFF8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.purple, size: 21),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  valor.trim().isEmpty ? textoVacio : valor,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
