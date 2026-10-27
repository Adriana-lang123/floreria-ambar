import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'cliente/home_cliente.dart';
import 'administrador/home_admin.dart';
import 'registro.dart';
import 'repartidor/home_repartidor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool ocultarPassword = true;
  bool cargando = false;
  bool googleInicializado = false;

  // =====================================================
  // INICIALIZAR GOOGLE
  // =====================================================

  @override
  void initState() {
    super.initState();
    inicializarGoogle();
  }

  Future<void> inicializarGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();

      if (mounted) {
        setState(() {
          googleInicializado = true;
        });
      }
    } catch (e) {
      debugPrint('Error inicializando Google: $e');
    }
  }

  // =====================================================
  // LOGIN CON CORREO Y CONTRASEÑA
  // =====================================================

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa correo y contraseña')),
      );
      return;
    }

    try {
      setState(() {
        cargando = true;
      });

      // =====================================================
      // AUTENTICACIÓN
      // =====================================================

      final UserCredential credencial = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: correo, password: password);

      final usuarioAuth = credencial.user;

      if (usuarioAuth == null) {
        throw Exception('No se pudo obtener el usuario autenticado');
      }

      final uid = usuarioAuth.uid;

      // =====================================================
      // BUSCAR USUARIO EN FIRESTORE
      // =====================================================

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!documento.exists) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No existe información registrada para este usuario'),
          ),
        );

        return;
      }

      final datos = documento.data();

      if (datos == null) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron leer los datos del usuario'),
          ),
        );

        return;
      }

      // =====================================================
      // OBTENER ROL
      // =====================================================

      final rol = (datos['rol'] ?? '').toString().trim().toLowerCase();

      debugPrint('==============================');
      debugPrint('CORREO: ${usuarioAuth.email}');
      debugPrint('UID: $uid');
      debugPrint('ROL: $rol');
      debugPrint('==============================');

      if (!mounted) return;

      navegarSegunRol(rol);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No se pudo iniciar sesión';

      if (e.code == 'invalid-credential') {
        mensaje = 'Correo o contraseña incorrectos';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido';
      } else if (e.code == 'user-disabled') {
        mensaje = 'Este usuario está deshabilitado';
      } else if (e.code == 'too-many-requests') {
        mensaje = 'Demasiados intentos. Intenta más tarde';
      } else if (e.code == 'user-not-found') {
        mensaje = 'No existe una cuenta con este correo';
      } else if (e.code == 'wrong-password') {
        mensaje = 'La contraseña es incorrecta';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión: $e')));
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // =====================================================
  // LOGIN CON GOOGLE
  // =====================================================

  Future<void> iniciarSesionGoogle() async {
    if (!googleInicializado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google todavía se está preparando. Intenta nuevamente.',
          ),
        ),
      );

      return;
    }

    try {
      setState(() {
        cargando = true;
      });

      // =====================================================
      // ABRIR SELECTOR DE CUENTAS DE GOOGLE
      // =====================================================

      final GoogleSignInAccount cuentaGoogle = await GoogleSignIn.instance
          .authenticate();

      // =====================================================
      // OBTENER TOKEN DE GOOGLE
      // =====================================================

      final GoogleSignInAuthentication googleAuth = cuentaGoogle.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google no proporcionó el token de autenticación.');
      }

      // =====================================================
      // CREAR CREDENCIAL PARA FIREBASE
      // =====================================================

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // =====================================================
      // AUTENTICAR EN FIREBASE
      // =====================================================

      final UserCredential credencial = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? usuarioAuth = credencial.user;

      if (usuarioAuth == null) {
        throw Exception('No se pudo obtener el usuario de Google.');
      }

      final String uid = usuarioAuth.uid;

      // =====================================================
      // BUSCAR USUARIO EN FIRESTORE
      // =====================================================

      final usuarioRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid);

      final documento = await usuarioRef.get();

      // =====================================================
      // SI ES NUEVO, CREARLO COMO CLIENTE
      // =====================================================

      if (!documento.exists) {
        await usuarioRef.set({
          'nombre': usuarioAuth.displayName ?? '',
          'apellidos': '',
          'correo': usuarioAuth.email ?? '',
          'telefono': '',
          'rol': 'cliente',
          'fotoPerfil': usuarioAuth.photoURL ?? '',
          'fechaRegistro': FieldValue.serverTimestamp(),
        });

        debugPrint('Nuevo usuario Google registrado como cliente.');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada correctamente con Google'),
          ),
        );

        navegarSegunRol('cliente');

        return;
      }

      // =====================================================
      // SI YA EXISTE, RESPETAR SU ROL
      // =====================================================

      final datos = documento.data();

      if (datos == null) {
        throw Exception('No se pudieron leer los datos del usuario.');
      }

      final rol = (datos['rol'] ?? 'cliente').toString().trim().toLowerCase();

      debugPrint('==============================');
      debugPrint('LOGIN GOOGLE');
      debugPrint('NOMBRE: ${usuarioAuth.displayName}');
      debugPrint('CORREO: ${usuarioAuth.email}');
      debugPrint('UID: $uid');
      debugPrint('ROL: $rol');
      debugPrint('==============================');

      if (!mounted) return;

      navegarSegunRol(rol);
    } on GoogleSignInException catch (e) {
      debugPrint('Error Google Sign-In: ${e.code}');

      if (!mounted) return;

      String mensaje = 'No se pudo iniciar sesión con Google';

      if (e.code == GoogleSignInExceptionCode.canceled) {
        mensaje = 'Inicio de sesión cancelado';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } on FirebaseAuthException catch (e) {
      debugPrint('Error Firebase Google: ${e.code}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de autenticación: ${e.message ?? e.code}'),
        ),
      );
    } catch (e) {
      debugPrint('Error general Google: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar sesión con Google: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // =====================================================
  // NAVEGAR SEGÚN ROL
  // =====================================================

  void navegarSegunRol(String rol) {
    switch (rol) {
      case 'admin':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeAdmin()),
          (route) => false,
        );
        break;

      case 'repartidor':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeRepartidor()),
          (route) => false,
        );
        break;

      case 'cliente':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeCliente()),
          (route) => false,
        );
        break;

      default:
        FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Rol no reconocido: "$rol"')));
        break;
    }
  }

  // =====================================================
  // LIBERAR CONTROLADORES
  // =====================================================

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF3F8),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),

          child: Column(
            children: [
              const SizedBox(height: 20),

              // =================================================
              // LOGO
              // =================================================
              Container(
                width: 95,
                height: 95,

                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.local_florist,
                  size: 55,
                  color: Colors.purple,
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // NOMBRE
              // =================================================
              const Text(
                'Florería Ámbar',

                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D1B33),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Flores para momentos especiales 🌸',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // =================================================
              // TARJETA DEL FORMULARIO
              // =================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.10),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Bienvenido',

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2D1B33),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Inicia sesión para continuar',

                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 25),

                    // =========================================
                    // CORREO
                    // =========================================
                    const Text(
                      'Correo electrónico',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xff403044),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: correoController,

                      keyboardType: TextInputType.emailAddress,

                      decoration: InputDecoration(
                        hintText: 'ejemplo@correo.com',

                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.purple,
                        ),

                        filled: true,

                        fillColor: const Color(0xffFAF7FA),

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
                          borderSide: const BorderSide(
                            color: Colors.purple,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================================
                    // CONTRASEÑA
                    // =========================================
                    const Text(
                      'Contraseña',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xff403044),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: passwordController,

                      obscureText: ocultarPassword,

                      decoration: InputDecoration(
                        hintText: 'Ingresa tu contraseña',

                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.purple,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,

                            color: Colors.grey,
                          ),

                          onPressed: () {
                            setState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                        ),

                        filled: true,

                        fillColor: const Color(0xffFAF7FA),

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
                          borderSide: const BorderSide(
                            color: Colors.purple,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =========================================
                    // BOTÓN LOGIN
                    // =========================================
                    SizedBox(
                      width: double.infinity,
                      height: 54,

                      child: ElevatedButton(
                        onPressed: cargando ? null : iniciarSesion,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,

                          foregroundColor: Colors.white,

                          elevation: 3,

                          shadowColor: Colors.purple.withOpacity(0.30),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        child: cargando
                            ? const SizedBox(
                                width: 24,
                                height: 24,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(Icons.login, size: 21),

                                  SizedBox(width: 8),

                                  Text(
                                    'INICIAR SESIÓN',

                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================================
                    // SEPARADOR
                    // =========================================
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),

                          child: Text(
                            'o',

                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),

                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================================
                    // GOOGLE
                    // =========================================
                    SizedBox(
                      width: double.infinity,
                      height: 54,

                      child: OutlinedButton(
                        onPressed: cargando || !googleInicializado
                            ? null
                            : iniciarSesionGoogle,

                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,

                          foregroundColor: Colors.black87,

                          side: BorderSide(color: Colors.grey.shade300),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            // LETRA G
                            Container(
                              width: 28,
                              height: 28,

                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),

                              alignment: Alignment.center,

                              child: const Text(
                                'G',

                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff4285F4),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              !googleInicializado
                                  ? 'Preparando Google...'
                                  : 'Continuar con Google',

                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // =================================================
              // REGISTRO
              // =================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text(
                      '¿No tienes cuenta?',

                      style: TextStyle(color: Colors.grey),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistroScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        'Regístrate',

                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Florería Ámbar',

                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
