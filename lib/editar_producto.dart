import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditarProductoScreen extends StatefulWidget {
  final String id;
  final Map<String, dynamic> producto;

  const EditarProductoScreen({
    super.key,

    required this.id,

    required this.producto,
  });

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController precioController;

  late String categoriaSeleccionada;

  late bool disponible;

  File? nuevaImagen;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(text: widget.producto['nombre']);

    descripcionController = TextEditingController(
      text: widget.producto['descripcion'],
    );

    precioController = TextEditingController(
      text: widget.producto['precio'].toString(),
    );

    categoriaSeleccionada = widget.producto['categoria'];

    disponible = widget.producto['disponible'] ?? true;
  }

  Future<void> seleccionarImagen() async {
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,

      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() {
        nuevaImagen = File(imagen.path);
      });
    }
  }

  Future<void> actualizarProducto() async {
    await FirebaseFirestore.instance
        .collection('productos')
        .doc(widget.id)
        .update({
          'nombre': nombreController.text.trim(),

          'descripcion': descripcionController.text.trim(),

          'precio': double.parse(precioController.text),

          'categoria': categoriaSeleccionada,

          'disponible': disponible,
        });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Producto actualizado')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        title: const Text('Editar producto'),

        backgroundColor: Colors.white,

        foregroundColor: Colors.black87,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            GestureDetector(
              onTap: seleccionarImagen,

              child: Container(
                height: 200,

                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  color: Colors.white,
                ),

                child: nuevaImagen != null
                    ? Image.file(nuevaImagen!, fit: BoxFit.cover)
                    : Image.network(
                        widget.producto['imagenUrl'],

                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 20),

            campo(nombreController, 'Nombre'),

            const SizedBox(height: 15),

            campo(descripcionController, 'Descripción'),

            const SizedBox(height: 15),

            campo(precioController, 'Precio'),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: categoriaSeleccionada,

              items: const [
                DropdownMenuItem(value: 'Ocasiones', child: Text('Ocasiones')),

                DropdownMenuItem(
                  value: 'Tipos de Arreglo',

                  child: Text('Tipos de Arreglo'),
                ),

                DropdownMenuItem(
                  value: 'Plantas y Eternas',

                  child: Text('Plantas y Eternas'),
                ),

                DropdownMenuItem(
                  value: 'Complementos',

                  child: Text('Complementos'),
                ),
              ],

              onChanged: (valor) {
                setState(() {
                  categoriaSeleccionada = valor!;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Producto disponible'),

              value: disponible,

              onChanged: (valor) {
                setState(() {
                  disponible = valor;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,

                  foregroundColor: Colors.white,
                ),

                onPressed: actualizarProducto,

                child: const Text('GUARDAR CAMBIOS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campo(TextEditingController controller, String texto) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        labelText: texto,

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
