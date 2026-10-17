import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        title: const Text(
          'Clientes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('rol', isEqualTo: 'cliente')
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
            return _sinClientes();
          }

          final clientes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(18),

            itemCount: clientes.length,

            itemBuilder: (context, index) {
              final cliente = clientes[index];

              final datos = cliente.data() as Map<String, dynamic>;

              final nombre = datos['nombre'] ?? 'Sin nombre';

              final apellidos = datos['apellidos'] ?? '';

              final correo = datos['correo'] ?? 'Sin correo';

              final telefono = datos['telefono'] ?? 'Sin teléfono';

              final nombreCompleto = '$nombre $apellidos'.trim();

              return Container(
                margin: const EdgeInsets.only(bottom: 15),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.08),

                      blurRadius: 12,

                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Row(
                    children: [
                      // FOTO / ICONO
                      Container(
                        width: 58,
                        height: 58,

                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.purple,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // INFORMACIÓN
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              nombreCompleto,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 7),

                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 5),

                                Expanded(
                                  child: Text(
                                    correo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  telefono,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ELIMINAR
                      IconButton(
                        tooltip: 'Eliminar cliente',

                        onPressed: () {
                          _confirmarEliminar(
                            context,
                            cliente.id,
                            nombreCompleto,
                          );
                        },

                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 25,
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

  // ==========================================
  // SIN CLIENTES
  // ==========================================

  Widget _sinClientes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 90,
            height: 90,

            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.people_outline,
              color: Colors.purple,
              size: 45,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No hay clientes registrados',

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            'Los clientes registrados aparecerán aquí',

            textAlign: TextAlign.center,

            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CONFIRMAR ELIMINACIÓN
  // ==========================================

  static Future<void> _confirmarEliminar(
    BuildContext context,
    String id,
    String nombre,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Eliminar cliente',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: Text('¿Estás seguro de eliminar a $nombre?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: () {
                Navigator.pop(context, true);
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
      await FirebaseFirestore.instance.collection('usuarios').doc(id).delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente eliminado correctamente')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
    }
  }
}
