import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'arreglos_personalizados_admin.dart';
import 'clientes.dart';
import '../login.dart';
import 'productos_admin.dart';
import 'pedidos_admin.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  // =========================================================
  // OBTENER FECHA DE ENTREGA
  // =========================================================

  static DateTime? _obtenerFechaEntrega(Map<String, dynamic> datos) {
    final fecha = datos['fechaEntrega'];

    if (fecha is Timestamp) {
      return fecha.toDate();
    }

    // Respaldo para pedidos antiguos que solo tengan texto.
    final fechaTexto = datos['fechaEntregaTexto']?.toString() ?? '';

    if (fechaTexto.isNotEmpty) {
      try {
        final partes = fechaTexto.split('/');

        if (partes.length == 3) {
          return DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // =========================================================
  // FORMATEAR FECHA
  // =========================================================

  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  // =========================================================
  // CREAR CLAVE DE FECHA
  // =========================================================

  static String _claveFecha(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '${fecha.year}-$mes-$dia';
  }

  // =========================================================
  // CONVERTIR HORA A MINUTOS PARA ORDENAR
  // =========================================================

  static int _horaAMinutos(String hora) {
    try {
      final texto = hora.trim().toUpperCase();

      // Formato tipo: 10:30 AM
      if (texto.contains('AM') || texto.contains('PM')) {
        final esPm = texto.contains('PM');
        final limpio = texto.replaceAll('AM', '').replaceAll('PM', '').trim();

        final partes = limpio.split(':');

        int horas = int.parse(partes[0]);
        final minutos = partes.length > 1 ? int.parse(partes[1]) : 0;

        if (esPm && horas != 12) {
          horas += 12;
        }

        if (!esPm && horas == 12) {
          horas = 0;
        }

        return (horas * 60) + minutos;
      }

      // Formato tipo: 14:30
      final partes = texto.split(':');

      if (partes.length >= 2) {
        return (int.parse(partes[0]) * 60) + int.parse(partes[1]);
      }
    } catch (_) {}

    return 9999;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Panel de administración',
          style: TextStyle(
            color: Color(0xff2D1B33),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_outlined, color: Colors.grey),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          // =================================================
          // ENCABEZADO
          // =================================================
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff8E44AD), Color(0xffA95CC7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Florería Ámbar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Panel de administración',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // =================================================
          // ENTREGAS PROGRAMADAS
          // =================================================
          const Text(
            'Entregas programadas',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xff2D1B33),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Consulta cuántas entregas están programadas por fecha y horario.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 15),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pedidos')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.purple),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'No se pudieron cargar las entregas programadas.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final documentos = snapshot.data?.docs ?? [];

              // fecha -> hora -> cantidad
              final Map<String, Map<String, int>> entregasPorFecha = {};

              // Guardamos DateTime para poder ordenar las fechas.
              final Map<String, DateTime> fechasOriginales = {};

              for (final documento in documentos) {
                final datos = documento.data() as Map<String, dynamic>;

                final estado = (datos['estado'] ?? 'Pendiente').toString();

                // Solo contar pedidos que aún deben entregarse.
                final estadosActivos = [
                  'Pendiente',
                  'Preparando',
                  'Listo para entregar',
                  'En camino',
                ];

                if (!estadosActivos.contains(estado)) {
                  continue;
                }

                final fecha = _obtenerFechaEntrega(datos);

                if (fecha == null) {
                  continue;
                }

                final hora = (datos['horaEntrega'] ?? 'Sin horario').toString();

                final clave = _claveFecha(fecha);

                fechasOriginales[clave] = fecha;

                entregasPorFecha.putIfAbsent(clave, () => {});

                entregasPorFecha[clave]![hora] =
                    (entregasPorFecha[clave]![hora] ?? 0) + 1;
              }

              if (entregasPorFecha.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.withOpacity(0.08)),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.grey,
                        size: 35,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No hay entregas programadas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }

              final fechas = entregasPorFecha.keys.toList();

              fechas.sort((a, b) {
                final fechaA = fechasOriginales[a]!;
                final fechaB = fechasOriginales[b]!;

                return fechaA.compareTo(fechaB);
              });

              int totalEntregas = 0;

              for (final fecha in fechas) {
                for (final cantidad in entregasPorFecha[fecha]!.values) {
                  totalEntregas += cantidad;
                }
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.purple.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOTAL GENERAL
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.purple,
                            size: 27,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total de entregas pendientes',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '$totalEntregas ${totalEntregas == 1 ? 'entrega' : 'entregas'}',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2D1B33),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    // FECHAS
                    ...fechas.map((claveFecha) {
                      final fecha = fechasOriginales[claveFecha]!;

                      final horarios = entregasPorFecha[claveFecha]!;

                      final listaHorarios = horarios.keys.toList();

                      listaHorarios.sort(
                        (a, b) => _horaAMinutos(a).compareTo(_horaAMinutos(b)),
                      );

                      int totalDia = 0;

                      for (final cantidad in horarios.values) {
                        totalDia += cantidad;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xffFAF7FB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.purple,
                                  size: 20,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    _formatearFecha(fecha),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2D1B33),
                                    ),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$totalDia ${totalDia == 1 ? 'entrega' : 'entregas'}',
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            ...listaHorarios.map((hora) {
                              final cantidad = horarios[hora] ?? 0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.purple.withOpacity(
                                            0.10,
                                          ),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.access_time,
                                        color: Colors.purple,
                                        size: 17,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        hora,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      '$cantidad ${cantidad == 1 ? 'entrega' : 'entregas'}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 2),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PedidosAdminScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Ver pedidos'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // =================================================
          // ADMINISTRACIÓN
          // =================================================
          const Text(
            'Administración',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xff2D1B33),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Administra los diferentes apartados de la florería.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 20),

          // =================================================
          // CLIENTES
          // =================================================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usuarios')
                .where('rol', isEqualTo: 'cliente')
                .snapshots(),
            builder: (context, snapshot) {
              int totalClientes = 0;

              if (snapshot.hasData) {
                totalClientes = snapshot.data!.docs.length;
              }

              return _adminOption(
                context: context,
                icono: Icons.people_outline,
                color: const Color(0xff7B4B9A),
                titulo: 'Clientes registrados',
                descripcion: 'Consulta los clientes de la florería',
                extra: '$totalClientes registrados',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClientesScreen()),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 14),

          // =================================================
          // PEDIDOS
          // =================================================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pedidos')
                .where('estado', isEqualTo: 'Pendiente')
                .snapshots(),
            builder: (context, snapshot) {
              int pedidosPendientes = 0;

              if (snapshot.hasData) {
                pedidosPendientes = snapshot.data!.docs.length;
              }

              return _adminOption(
                context: context,
                icono: Icons.shopping_bag_outlined,
                color: const Color(0xffC05A86),
                titulo: 'Pedidos',
                descripcion: 'Consulta y actualiza los pedidos realizados',
                extra: '$pedidosPendientes pendientes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PedidosAdminScreen(),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 14),

          // =================================================
          // PRODUCTOS
          // =================================================
          _adminOption(
            context: context,
            icono: Icons.local_florist_outlined,
            color: const Color(0xffD08B4B),
            titulo: 'Productos',
            descripcion: 'Consulta los productos disponibles',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductosAdminScreen()),
              );
            },
          ),

          const SizedBox(height: 14),

          // =================================================
          // ARREGLOS PERSONALIZADOS
          // =================================================
          _adminOption(
            context: context,
            icono: Icons.auto_awesome_outlined,
            color: const Color(0xff9B59B6),
            titulo: 'Arreglos personalizados',
            descripcion: 'Revisa las solicitudes de los clientes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArreglosPersonalizadosAdminScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // =================================================
          // INFORMACIÓN
          // =================================================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.purple.withOpacity(0.08)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.purple, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Desde este panel puedes consultar '
                    'clientes, pedidos, productos y '
                    'solicitudes personalizadas.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // OPCIÓN DEL PANEL
  // =========================================================

  static Widget _adminOption({
    required BuildContext context,
    required IconData icono,
    required Color color,
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
    String? extra,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: color, size: 28),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2D1B33),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    if (extra != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        extra,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xffF7F3F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
