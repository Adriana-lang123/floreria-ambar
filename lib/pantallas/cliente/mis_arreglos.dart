import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MisArreglosScreen extends StatelessWidget {
  const MisArreglosScreen({super.key});

  // =====================================================
  // FECHA
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
  // COLOR DEL ESTADO
  // =====================================================

  Color _colorEstado(String estado) {
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

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return Icons.check_circle_outline;

      case 'Rechazado':
        return Icons.cancel_outlined;

      default:
        return Icons.access_time;
    }
  }

  // =====================================================
  // MENSAJE DEL ESTADO
  // =====================================================

  String _mensajeEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return 'La florería aceptó tu solicitud de arreglo personalizado.';

      case 'Rechazado':
        return 'La florería no aceptó esta solicitud de arreglo personalizado.';

      default:
        return 'Tu solicitud está siendo revisada por la florería.';
    }
  }

  // =====================================================
  // SUBTÍTULO
  // =====================================================

  String _subtituloEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return 'Tu solicitud fue aceptada';

      case 'Rechazado':
        return 'Tu solicitud fue rechazada';

      default:
        return 'Tu solicitud está pendiente';
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

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
        foregroundColor: Colors.black87,
        title: const Text(
          'Mis arreglos personalizados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('arreglos_personalizados')
            .where('usuarioId', isEqualTo: usuario.uid)
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
                padding: const EdgeInsets.all(25),
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
                      'No se pudieron cargar tus solicitudes',
                      textAlign: TextAlign.center,
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_florist_outlined,
                      size: 75,
                      color: Colors.purple.shade200,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Aún no tienes solicitudes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Cuando envíes una solicitud de arreglo personalizado, aparecerá aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final arreglos = snapshot.data!.docs.toList();

          // Mostrar primero las solicitudes más recientes.
          arreglos.sort((a, b) {
            final datosA = a.data() as Map<String, dynamic>;
            final datosB = b.data() as Map<String, dynamic>;

            final fechaA = datosA['fechaSolicitud'];
            final fechaB = datosB['fechaSolicitud'];

            if (fechaA is Timestamp && fechaB is Timestamp) {
              return fechaB.compareTo(fechaA);
            }

            return 0;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: arreglos.length,

            itemBuilder: (context, index) {
              final documento = arreglos[index];

              final datos = documento.data() as Map<String, dynamic>;

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

              final colorEstado = _colorEstado(estado);

              final iconoEstado = _iconoEstado(estado);

              return Card(
                margin: const EdgeInsets.only(bottom: 18),
                elevation: 3,
                shadowColor: Colors.purple.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =================================================
                      // ENCABEZADO
                      // =================================================
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: colorEstado.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.local_florist,
                              color: colorEstado,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Arreglo personalizado',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  _subtituloEstado(estado),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: colorEstado.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(iconoEstado, color: colorEstado, size: 16),

                                const SizedBox(width: 5),

                                Text(
                                  estado,
                                  style: TextStyle(
                                    color: colorEstado,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // INFORMACIÓN PRINCIPAL
                      // =================================================
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
                        titulo: 'Colores',
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
                        valor: presupuesto.isEmpty
                            ? 'No especificado'
                            : '\$$presupuesto MXN',
                      ),

                      const SizedBox(height: 20),

                      const Divider(),

                      const SizedBox(height: 15),

                      // =================================================
                      // PREFERENCIAS
                      // =================================================
                      const Text(
                        'Tus preferencias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _detalleTexto(
                        titulo: 'Flores que deseas',
                        valor: floresDeseadas,
                        textoVacio: 'A elección de la florista',
                        icono: Icons.local_florist,
                      ),

                      const SizedBox(height: 10),

                      _detalleTexto(
                        titulo: 'Flores que no deseas',
                        valor: floresNoDeseadas,
                        textoVacio: 'Ninguna',
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
                                    ? 'Permitiste sustituciones de flores respetando el estilo y colores.'
                                    : 'No permitiste sustituciones de flores.',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      _detalleTexto(
                        titulo: 'Descripción',
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

                      // =================================================
                      // ENTREGA
                      // =================================================
                      const Text(
                        'Entrega',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

                      const SizedBox(height: 18),

                      // =================================================
                      // MENSAJE DEL ESTADO
                      // =================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorEstado.withOpacity(0.20),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(iconoEstado, color: colorEstado),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                _mensajeEstado(estado),
                                style: TextStyle(
                                  color: colorEstado,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
  // DATO
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
  // DETALLE
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
