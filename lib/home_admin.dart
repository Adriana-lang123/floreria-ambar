import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'arreglos_personalizados_admin.dart';
import 'clientes.dart';
import 'login.dart';
import 'productos_admin.dart';
import 'pedidos_admin.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

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
                // ICONO
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

                // TEXTO
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
          // TITULO
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

  // =======================================================
  // OPCIÓN DEL PANEL
  // =======================================================

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
              // ===========================================
              // ICONO
              // ===========================================
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

              // ===========================================
              // INFORMACIÓN
              // ===========================================
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

              // ===========================================
              // FLECHA
              // ===========================================
              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: const Color(0xffF7F3F8),

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
