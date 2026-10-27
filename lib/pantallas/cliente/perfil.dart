import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ubicacion_screen.dart';
import 'login.dart';
import 'pedidos.dart';
import 'arreglos_personalizados.dart';
import 'mis_arreglos.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi perfil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No se encontró información del usuario'),
            );
          }

          final datos = snapshot.data!.data() as Map<String, dynamic>;

          final nombre = '${datos['nombre'] ?? ''} ${datos['apellidos'] ?? ''}'
              .trim();

          final correo = datos['correo'] ?? '';

          final telefono = datos['telefono'] ?? '';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

            children: [
              // ==========================================
              // ENCABEZADO DEL PERFIL
              // ==========================================
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 95,
                      height: 95,

                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.person,
                        size: 55,
                        color: Colors.purple,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      nombre.isEmpty ? 'Usuario' : nombre,

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      correo,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==========================================
              // INFORMACIÓN PERSONAL
              // ==========================================
              const Text(
                'Información personal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    _datoPerfil(
                      icono: Icons.person_outline,
                      titulo: 'Nombre',
                      valor: nombre,
                    ),

                    const Divider(height: 25),

                    _datoPerfil(
                      icono: Icons.email_outlined,
                      titulo: 'Correo',
                      valor: correo,
                    ),

                    const Divider(height: 25),

                    _datoPerfil(
                      icono: Icons.phone_outlined,
                      titulo: 'Teléfono',
                      valor: telefono,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // OPCIONES
              // ==========================================
              const Text(
                'Opciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // MIS PEDIDOS
              _opcionPerfil(
                icono: Icons.shopping_bag_outlined,
                titulo: 'Mis pedidos',
                descripcion: 'Consulta tus pedidos y su estado',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PedidosScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              _opcionPerfil(
                icono: Icons.local_florist_outlined,
                titulo: 'Mis arreglos personalizados',
                descripcion: 'Consulta tus solicitudes y su estado',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MisArreglosScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // UBICACIÓN
              _opcionPerfil(
                icono: Icons.location_on_outlined,
                titulo: 'Ubicación',
                descripcion: 'Consulta nuestra ubicación',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UbicacionScreen()),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ==========================================
              // CERRAR SESIÓN
              // ==========================================
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.shade200),

                  minimumSize: const Size(double.infinity, 52),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },

                icon: const Icon(Icons.logout),

                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ======================================================
  // DATO DE INFORMACIÓN PERSONAL
  // ======================================================

  static Widget _datoPerfil({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icono, color: Colors.purple, size: 22),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 3),

              Text(
                valor.isEmpty ? 'No registrado' : valor,

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

  // ======================================================
  // OPCIÓN QUE SÍ ES PRESIONABLE
  // ======================================================

  static Widget _opcionPerfil({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icono, color: Colors.purple, size: 25),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      descripcion,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
