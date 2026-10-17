import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'carrito/carrito_provider.dart';

class PedidoScreen extends StatefulWidget {
  final CarritoProvider carrito;

  const PedidoScreen({super.key, required this.carrito});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final calleController = TextEditingController();
  final numeroController = TextEditingController();
  final coloniaController = TextEditingController();
  final municipioController = TextEditingController();
  final codigoPostalController = TextEditingController();
  final referenciaController = TextEditingController();

  DateTime? fechaEntrega;
  TimeOfDay? horaEntrega;

  bool enviando = false;

  @override
  void dispose() {
    calleController.dispose();
    numeroController.dispose();
    coloniaController.dispose();
    municipioController.dispose();
    codigoPostalController.dispose();
    referenciaController.dispose();
    super.dispose();
  }

  // =====================================================
  // SELECCIONAR FECHA
  // =====================================================

  Future<void> seleccionarFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      helpText: 'Selecciona la fecha de entrega',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null) {
      setState(() {
        fechaEntrega = fecha;
      });
    }
  }

  // =====================================================
  // SELECCIONAR HORA
  // =====================================================

  Future<void> seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Selecciona la hora de entrega',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (hora != null) {
      final minutosSeleccionados = hora.hour * 60 + hora.minute;

      // Horario de la florería: 8:00 AM a 9:00 PM
      const apertura = 8 * 60;
      const cierre = 21 * 60;

      if (minutosSeleccionados < apertura || minutosSeleccionados > cierre) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nuestro horario de entrega es de 8:00 AM a 9:00 PM'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      setState(() {
        horaEntrega = hora;
      });
    }
  }
  // =====================================================
  // MOSTRAR FECHA
  // =====================================================

  String mostrarFecha() {
    if (fechaEntrega == null) {
      return 'Selecciona una fecha';
    }

    return '${fechaEntrega!.day.toString().padLeft(2, '0')}/'
        '${fechaEntrega!.month.toString().padLeft(2, '0')}/'
        '${fechaEntrega!.year}';
  }

  // =====================================================
  // MOSTRAR MENSAJE
  // =====================================================

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  // =====================================================
  // CONFIRMAR PEDIDO
  // =====================================================

  Future<void> confirmarPedido() async {
    // CALLE
    if (calleController.text.trim().isEmpty) {
      mostrarMensaje('Escribe la calle de entrega');
      return;
    }

    // NÚMERO
    if (numeroController.text.trim().isEmpty) {
      mostrarMensaje('Escribe el número del domicilio');
      return;
    }

    // COLONIA
    if (coloniaController.text.trim().isEmpty) {
      mostrarMensaje('Escribe la colonia');
      return;
    }

    // MUNICIPIO
    if (municipioController.text.trim().isEmpty) {
      mostrarMensaje('Escribe el municipio o alcaldía');
      return;
    }

    // CÓDIGO POSTAL
    if (codigoPostalController.text.trim().isEmpty) {
      mostrarMensaje('Escribe el código postal');
      return;
    }

    if (codigoPostalController.text.trim().length != 5) {
      mostrarMensaje('El código postal debe tener 5 dígitos');
      return;
    }

    // REFERENCIA
    if (referenciaController.text.trim().isEmpty) {
      mostrarMensaje('Escribe una referencia para ayudar al repartidor');
      return;
    }

    if (referenciaController.text.trim().length < 10) {
      mostrarMensaje('Escribe una referencia más detallada del domicilio');
      return;
    }

    // FECHA
    if (fechaEntrega == null) {
      mostrarMensaje('Selecciona la fecha de entrega');
      return;
    }

    // HORA
    if (horaEntrega == null) {
      mostrarMensaje('Selecciona la hora de entrega');
      return;
    }
    final minutosEntrega = horaEntrega!.hour * 60 + horaEntrega!.minute;

    const apertura = 8 * 60;
    const cierre = 21 * 60;

    if (minutosEntrega < apertura || minutosEntrega > cierre) {
      mostrarMensaje('La hora de entrega debe estar entre 8:00 AM y 9:00 PM');
      return;
    }
    // USUARIO
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      mostrarMensaje('Debes iniciar sesión para realizar el pedido');
      return;
    }

    // CARRITO
    final carrito = widget.carrito;

    if (carrito.productos.isEmpty) {
      mostrarMensaje('Tu carrito está vacío');
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      final fechaHoraEntrega = DateTime(
        fechaEntrega!.year,
        fechaEntrega!.month,
        fechaEntrega!.day,
        horaEntrega!.hour,
        horaEntrega!.minute,
      );

      // OBTENER DATOS DEL CLIENTE
      final usuarioDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      final datosUsuario = usuarioDoc.data() ?? {};

      final nombreCliente = datosUsuario['nombre'] ?? 'Cliente';

      final apellidosCliente = datosUsuario['apellidos'] ?? '';

      final correoCliente = datosUsuario['correo'] ?? usuario.email ?? '';

      final telefonoCliente = datosUsuario['telefono'] ?? '';

      // DIRECCIÓN COMPLETA EN TEXTO
      final direccionCompleta =
          '${calleController.text.trim()} '
          '${numeroController.text.trim()}, '
          '${coloniaController.text.trim()}, '
          '${municipioController.text.trim()}, '
          'C.P. ${codigoPostalController.text.trim()}';

      // GUARDAR PEDIDO
      await FirebaseFirestore.instance.collection('pedidos').add({
        // CLIENTE
        'usuarioId': usuario.uid,
        'nombreCliente': '$nombreCliente $apellidosCliente'.trim(),
        'correoCliente': correoCliente,
        'telefonoCliente': telefonoCliente,

        // DIRECCIÓN
        'direccion': direccionCompleta,

        'calle': calleController.text.trim(),
        'numero': numeroController.text.trim(),
        'colonia': coloniaController.text.trim(),
        'municipio': municipioController.text.trim(),
        'codigoPostal': codigoPostalController.text.trim(),

        // REFERENCIA
        'referencia': referenciaController.text.trim(),

        // ENTREGA
        'fechaEntrega': Timestamp.fromDate(fechaHoraEntrega),

        'fechaEntregaTexto': mostrarFecha(),

        'horaEntrega': horaEntrega!.format(context),

        // PEDIDO
        'productos': carrito.productos,
        'total': carrito.total,

        // ESTADO
        'estado': 'Pendiente',

        // FECHA DEL PEDIDO
        'fecha': FieldValue.serverTimestamp(),
      });

      carrito.vaciarCarrito();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Expanded(child: Text('¡Pedido realizado!')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tu pedido fue registrado correctamente.'),

                const SizedBox(height: 15),

                Text(
                  '📍 $direccionCompleta',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                Text(
                  '🏠 Referencia: '
                  '${referenciaController.text.trim()}',
                ),

                const SizedBox(height: 8),

                Text('📅 Fecha: ${mostrarFecha()}'),

                const SizedBox(height: 5),

                Text(
                  '🕐 Hora: '
                  '${horaEntrega!.format(context)}',
                ),

                const SizedBox(height: 15),

                const Text(
                  'La florería revisará tu pedido '
                  'y utilizará estos datos para realizar la entrega.',
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      mostrarMensaje('No se pudo realizar el pedido: $e');
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  // =====================================================
  // CAMPO PERSONALIZADO
  // =====================================================

  Widget campoTexto({
    required String titulo,
    required String hint,
    required TextEditingController controller,
    required IconData icono,
    TextInputType? tipoTeclado,
    List<TextInputFormatter>? formato,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,
          keyboardType: tipoTeclado,
          inputFormatters: formato,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: Icon(icono, color: Colors.purple),
            filled: true,
            fillColor: const Color(0xffFAF7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final carrito = widget.carrito;

    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Datos de entrega',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // =================================================
          // ENCABEZADO
          // =================================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.purple,
                  size: 32,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de entrega',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Ingresa datos reales y completos. '
                        'El repartidor utilizará esta información '
                        'para localizar tu domicilio.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // =================================================
          // DIRECCIÓN
          // =================================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.purple),

                    SizedBox(width: 8),

                    Text(
                      'Dirección de entrega',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  'Completa todos los campos para evitar problemas con la entrega.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 18),

                campoTexto(
                  titulo: 'Calle *',
                  hint: 'Ej. Avenida Reforma',
                  controller: calleController,
                  icono: Icons.signpost_outlined,
                ),

                const SizedBox(height: 15),

                campoTexto(
                  titulo: 'Número exterior *',
                  hint: 'Ej. 125',
                  controller: numeroController,
                  icono: Icons.home_outlined,
                ),

                const SizedBox(height: 15),

                campoTexto(
                  titulo: 'Colonia *',
                  hint: 'Ej. Centro',
                  controller: coloniaController,
                  icono: Icons.location_city_outlined,
                ),

                const SizedBox(height: 15),

                campoTexto(
                  titulo: 'Municipio / Alcaldía *',
                  hint: 'Ej. Tultepec',
                  controller: municipioController,
                  icono: Icons.apartment_outlined,
                ),

                const SizedBox(height: 15),

                campoTexto(
                  titulo: 'Código postal *',
                  hint: 'Ej. 54960',
                  controller: codigoPostalController,
                  icono: Icons.markunread_mailbox_outlined,
                  tipoTeclado: TextInputType.number,
                  maxLength: 5,
                  formato: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =================================================
          // REFERENCIA
          // =================================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.home_work_outlined, color: Colors.purple),

                    SizedBox(width: 8),

                    Text(
                      'Referencia del domicilio',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                const Text(
                  'Describe cómo identificar el domicilio. '
                  'Este dato es obligatorio y ayudará al repartidor.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 15),

                campoTexto(
                  titulo: 'Referencia *',
                  hint:
                      'Ej. Casa blanca de dos pisos, portón negro, frente a una farmacia.',
                  controller: referenciaController,
                  icono: Icons.info_outline,
                  maxLines: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =================================================
          // FECHA Y HORA
          // =================================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha y hora de entrega',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                GestureDetector(
                  onTap: seleccionarFecha,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xffFAF7FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.purple),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            mostrarFecha(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: seleccionarHora,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xffFAF7FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.purple),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            horaEntrega == null
                                ? 'Selecciona una hora'
                                : horaEntrega!.format(context),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =================================================
          // TOTAL
          // =================================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total del pedido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                Text(
                  'MXN \$${carrito.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =================================================
          // CONFIRMAR
          // =================================================
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: enviando ? null : confirmarPedido,
              icon: enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                enviando ? 'Registrando pedido...' : 'CONFIRMAR PEDIDO',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
