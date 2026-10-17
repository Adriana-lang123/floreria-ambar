import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final nombreController = TextEditingController();

  final descripcionController = TextEditingController();

  final precioController = TextEditingController();

  File? imagenSeleccionada;

  String categoriaSeleccionada = 'Ocasiones';

  bool disponible = true;

  bool cargando = false;

  final picker = ImagePicker();

  // ===============================
  // SELECCIONAR IMAGEN
  // ===============================

  Future<void> seleccionarImagen() async {
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,

      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() {
        imagenSeleccionada = File(imagen.path);
      });
    }
  }

  // ===============================
  // CLOUDINARY
  // ===============================

  Future<String?> subirImagenCloudinary(File imagen) async {
    const cloudName = "ufxnagva";

    const uploadPreset = "floreria_ambar";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest('POST', url);

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(await http.MultipartFile.fromPath('file', imagen.path));

    final response = await request.send();

    final respuesta = await response.stream.bytesToString();

    print("CLOUDINARY ${response.statusCode}");

    print(respuesta);

    if (response.statusCode == 200) {
      final data = jsonDecode(respuesta);

      return data['secure_url'];
    }

    return null;
  }

  // ===============================
  // GUARDAR PRODUCTO
  // ===============================

  Future<void> guardarProducto() async {
    if (nombreController.text.trim().isEmpty ||
        precioController.text.trim().isEmpty ||
        imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos y selecciona imagen'),
        ),
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final imagenUrl = await subirImagenCloudinary(imagenSeleccionada!);

      if (imagenUrl == null) {
        throw Exception('No se pudo subir la imagen');
      }

      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': nombreController.text.trim(),

        'descripcion': descripcionController.text.trim(),

        'precio': double.parse(precioController.text.trim()),

        'categoria': categoriaSeleccionada,

        'imagenUrl': imagenUrl,

        'disponible': disponible,

        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          'Agregar producto',

          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
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
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: imagenSeleccionada == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.add_photo_alternate,

                            size: 60,

                            color: Colors.purple,
                          ),

                          SizedBox(height: 10),

                          Text('Seleccionar imagen'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: Image.file(
                          imagenSeleccionada!,

                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            campo(nombreController, 'Nombre del producto', Icons.local_florist),

            const SizedBox(height: 15),

            campo(descripcionController, 'Descripción', Icons.description),

            const SizedBox(height: 15),

            campo(
              precioController,

              'Precio',

              Icons.attach_money,

              teclado: TextInputType.number,
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: categoriaSeleccionada,

              decoration: InputDecoration(
                labelText: 'Categoría',

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),

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
                if (valor != null) {
                  setState(() {
                    categoriaSeleccionada = valor;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            SwitchListTile(
              title: const Text('Producto disponible'),

              value: disponible,

              activeColor: Colors.purple,

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

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: cargando ? null : guardarProducto,

                child: cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GUARDAR PRODUCTO',

                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campo(
    TextEditingController controller,

    String texto,

    IconData icono, {

    TextInputType? teclado,
  }) {
    return TextField(
      controller: controller,

      keyboardType: teclado,

      decoration: InputDecoration(
        labelText: texto,

        prefixIcon: Icon(icono, color: Colors.purple),

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
