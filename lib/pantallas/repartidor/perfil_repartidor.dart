import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';

class PerfilRepartidorScreen extends StatelessWidget {
  const PerfilRepartidorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('No hay sesión iniciada')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Mi perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No se encontró la información del repartidor'),
            );
          }

          final datos = snapshot.data!.data() as Map<String, dynamic>;

          final nombre = '${datos['nombre'] ?? ''} ${datos['apellidos'] ?? ''}'
              .trim();

          final correo = datos['correo'] ?? usuario.email ?? '';

          final telefono = datos['telefono'] ?? 'No registrado';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              // FOTO / ICONO
              Center(
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delivery_dining,
                    size: 58,
                    color: Colors.purple,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Text(
                  nombre.isEmpty ? 'Repartidor' : nombre,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              const Center(
                child: Text(
                  'Repartidor',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _datoPerfil(
                      icono: Icons.person_outline,
                      titulo: 'Nombre',
                      valor: nombre,
                    ),

                    const Divider(height: 26),

                    _datoPerfil(
                      icono: Icons.email_outlined,
                      titulo: 'Correo',
                      valor: correo,
                    ),

                    const Divider(height: 26),

                    _datoPerfil(
                      icono: Icons.phone_outlined,
                      titulo: 'Teléfono',
                      valor: telefono,
                    ),

                    const Divider(height: 26),

                    _datoPerfil(
                      icono: Icons.badge_outlined,
                      titulo: 'Rol',
                      valor: 'Repartidor',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // CERRAR SESIÓN
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
}
