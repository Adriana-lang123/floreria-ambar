import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;
  bool mostrarPassword = false;

  // ==========================================
  // VALIDAR NOMBRE Y APELLIDOS
  // ==========================================

  bool validarNombre(String texto) {
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');

    return texto.trim().length >= 2 && regex.hasMatch(texto.trim());
  }

  // ==========================================
  // VALIDAR TELÉFONO
  // ==========================================

  bool validarTelefono(String texto) {
    return RegExp(r'^[0-9]{10}$').hasMatch(texto.trim());
  }

  // ==========================================
  // VALIDAR CORREO
  // ==========================================

  bool validarCorreo(String texto) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(texto.trim());
  }

  // ==========================================
  // VALIDAR CONTRASEÑA
  // EXACTAMENTE 8 NÚMEROS
  // ==========================================

  bool validarPassword(String texto) {
    return RegExp(r'^[0-9]{8}$').hasMatch(texto);
  }

  // ==========================================
  // REGISTRAR USUARIO
  // ==========================================

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final apellidos = apellidosController.text.trim();
    final telefono = telefonoController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    // CAMPOS VACÍOS
    if (nombre.isEmpty ||
        apellidos.isEmpty ||
        telefono.isEmpty ||
        correo.isEmpty ||
        password.isEmpty) {
      _mensaje('Completa todos los campos');
      return;
    }

    // NOMBRE
    if (!validarNombre(nombre)) {
      _mensaje('El nombre solo debe contener letras');
      return;
    }

    // APELLIDOS
    if (!validarNombre(apellidos)) {
      _mensaje('Los apellidos solo deben contener letras');
      return;
    }

    // TELÉFONO
    if (!validarTelefono(telefono)) {
      _mensaje('El teléfono debe tener exactamente 10 números');
      return;
    }

    // CORREO
    if (!validarCorreo(correo)) {
      _mensaje('Escribe un correo electrónico válido');
      return;
    }

    // CONTRASEÑA
    if (!validarPassword(password)) {
      _mensaje('La contraseña debe tener exactamente 8 números');
      return;
    }

    try {
      setState(() {
        cargando = true;
      });

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: correo, password: password);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'correo': correo,
        'rol': 'cliente',
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada correctamente! 🌸'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No se pudo crear la cuenta';

      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña no es válida';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido';
      }

      _mensaje(mensaje);
    } catch (e) {
      _mensaje('Ocurrió un error al registrar la cuenta');
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // ==========================================
  // MENSAJE
  // ==========================================

  void _mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ==========================================
  // CAMPO PERSONALIZADO
  // ==========================================

  Widget campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      maxLength: maxLength,

      decoration: InputDecoration(
        labelText: label,

        counterText: '',

        prefixIcon: Icon(icono, color: Colors.purple),

        suffixIcon: suffixIcon,

        filled: true,
        fillColor: Colors.white,

        labelStyle: const TextStyle(color: Colors.grey),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        centerTitle: true,

        title: const Text(
          'Crear cuenta',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),

        child: Column(
          children: [
            // ==========================================
            // ENCABEZADO
            // ==========================================
            Container(
              width: 75,
              height: 75,

              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.person_add_alt_1,
                color: Colors.purple,
                size: 38,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Crea tu cuenta',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              'Regístrate para disfrutar de Florería Ámbar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 28),

            // ==========================================
            // DATOS PERSONALES
            // ==========================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(22),

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
                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      'Datos personales',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  campo(
                    controller: nombreController,
                    label: 'Nombre',
                    icono: Icons.person_outline,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  campo(
                    controller: apellidosController,
                    label: 'Apellidos',
                    icono: Icons.people_outline,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  campo(
                    controller: telefonoController,
                    label: 'Teléfono',
                    icono: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                  ),

                  const SizedBox(height: 14),

                  campo(
                    controller: correoController,
                    label: 'Correo electrónico',
                    icono: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==========================================
            // CONTRASEÑA
            // ==========================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(22),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Contraseña',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Debe contener exactamente 8 números.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 15),

                  campo(
                    controller: passwordController,
                    label: 'Contraseña',
                    icono: Icons.lock_outline,
                    obscureText: !mostrarPassword,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 8,

                    suffixIcon: IconButton(
                      icon: Icon(
                        mostrarPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),

                      onPressed: () {
                        setState(() {
                          mostrarPassword = !mostrarPassword;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==========================================
            // BOTÓN REGISTRARSE
            // ==========================================
            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                onPressed: cargando ? null : registrarUsuario,

                child: cargando
                    ? const SizedBox(
                        width: 24,
                        height: 24,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'CREAR CUENTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
