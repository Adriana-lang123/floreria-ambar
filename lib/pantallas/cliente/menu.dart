import 'package:flutter/material.dart';
import 'arreglos_personalizados.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Menú',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          menuItem(
            context,
            'Personalizar arreglo',
            'Crea un arreglo floral único a tu gusto',
            Icons.local_florist,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalizadaScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    String titulo,
    String descripcion,
    IconData icono,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icono, color: Colors.purple, size: 32),
        ),

        title: Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(descripcion),
        ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 18),

        onTap: onTap,
      ),
    );
  }
}
