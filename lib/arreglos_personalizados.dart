import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalizadaScreen extends StatefulWidget {
  const PersonalizadaScreen({super.key});

  @override
  State<PersonalizadaScreen> createState() => _PersonalizadaScreenState();
}

class _PersonalizadaScreenState extends State<PersonalizadaScreen> {
  // =========================================================
  // DATOS DEL FORMULARIO
  // =========================================================

  String tipoArreglo = 'Ramo';
  String estiloSeleccionado = 'Romántico';
  String tamanoSeleccionado = 'Mediano';
  String ocasionSeleccionada = 'Cumpleaños';
  String coloresSeleccionados = 'Tonos pastel';
  bool permiteSustitucion = true;

  final TextEditingController presupuestoController = TextEditingController();

  final TextEditingController floresDeseadasController =
      TextEditingController();

  final TextEditingController floresNoDeseadasController =
      TextEditingController();

  final TextEditingController mensajeTarjetaController =
      TextEditingController();

  final TextEditingController descripcionController = TextEditingController();

  DateTime? fechaEntrega;
  TimeOfDay? horaEntrega;

  bool enviando = false;

  // =========================================================
  // LISTAS
  // =========================================================

  final List<String> tiposArreglo = [
    'Ramo',
    'Bouquet',
    'Caja floral',
    'Canasta',
    'Arreglo en base',
    'Otro',
  ];

  final List<String> estilos = [
    'Romántico',
    'Elegante',
    'Alegre',
    'Delicado',
    'Tropical',
    'Minimalista',
    'A elección de la florista',
  ];

  final List<String> tamanos = ['Pequeño', 'Mediano', 'Grande'];

  final List<String> ocasiones = [
    'Cumpleaños',
    'Aniversario',
    'Graduación',
    'Agradecimiento',
    'Romántico',
    'Felicitación',
    'Otro',
  ];

  final List<String> opcionesColores = [
    'Rosa y blanco',
    'Rojo y blanco',
    'Amarillo y blanco',
    'Tonos pastel',
    'Colores vivos',
    'Tonos claros',
    'Tonos cálidos',
    'Tonos elegantes',
    'A elección de la florista',
  ];

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    presupuestoController.dispose();
    floresDeseadasController.dispose();
    floresNoDeseadasController.dispose();
    mensajeTarjetaController.dispose();
    descripcionController.dispose();

    super.dispose();
  }

  // =========================================================
  // SELECCIONAR FECHA
  // =========================================================

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

  // =========================================================
  // SELECCIONAR HORA
  // =========================================================

  Future<void> seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Selecciona la hora de entrega',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (hora == null) return;

    final minutos = hora.hour * 60 + hora.minute;

    const apertura = 8 * 60;
    const cierre = 21 * 60;

    if (minutos < apertura || minutos > cierre) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora de entrega debe estar entre 8:00 AM y 9:00 PM.',
          ),
        ),
      );

      return;
    }

    setState(() {
      horaEntrega = hora;
    });
  }

  // =========================================================
  // ENVIAR SOLICITUD
  // =========================================================

  Future<void> solicitarArreglo() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para solicitar un arreglo.'),
        ),
      );
      return;
    }

    // PRESUPUESTO OBLIGATORIO
    if (presupuestoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu presupuesto aproximado.')),
      );
      return;
    }

    // DESCRIPCIÓN OBLIGATORIA
    if (descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuéntanos cómo te gustaría que fuera tu arreglo.'),
        ),
      );
      return;
    }

    if (fechaEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de entrega.')),
      );
      return;
    }

    if (horaEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la hora de entrega.')),
      );
      return;
    }

    final minutosEntrega = horaEntrega!.hour * 60 + horaEntrega!.minute;

    const apertura = 8 * 60;
    const cierre = 21 * 60;

    if (minutosEntrega < apertura || minutosEntrega > cierre) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora de entrega debe estar entre 8:00 AM y 9:00 PM.',
          ),
        ),
      );
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      final fechaCompleta = DateTime(
        fechaEntrega!.year,
        fechaEntrega!.month,
        fechaEntrega!.day,
        horaEntrega!.hour,
        horaEntrega!.minute,
      );

      await FirebaseFirestore.instance.collection('arreglos_personalizados').add({
        'usuarioId': usuario.uid,
        'correoUsuario': usuario.email ?? '',

        'tipoArreglo': tipoArreglo,

        'estilo': estiloSeleccionado,

        'tamano': tamanoSeleccionado,

        'ocasion': ocasionSeleccionada,

        'colores': coloresSeleccionados,

        'presupuesto': presupuestoController.text.trim(),

        'floresDeseadas': floresDeseadasController.text.trim(),

        'floresNoDeseadas': floresNoDeseadasController.text.trim(),

        'mensajeTarjeta': mensajeTarjetaController.text.trim(),

        'descripcion': descripcionController.text.trim(),

        'permiteSustitucion': permiteSustitucion,

        'fechaEntrega': Timestamp.fromDate(fechaCompleta),

        'fechaEntregaTexto':
            '${fechaEntrega!.day}/${fechaEntrega!.month}/${fechaEntrega!.year}',

        'horaEntrega': horaEntrega!.format(context),

        'estado': 'Pendiente',

        'fechaSolicitud': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // LIMPIAR FORMULARIO

      presupuestoController.clear();
      floresDeseadasController.clear();
      floresNoDeseadasController.clear();
      mensajeTarjetaController.clear();
      descripcionController.clear();

      setState(() {
        tipoArreglo = 'Ramo';
        estiloSeleccionado = 'Romántico';
        tamanoSeleccionado = 'Mediano';
        ocasionSeleccionada = 'Cumpleaños';
        coloresSeleccionados = 'Tonos pastel';
        permiteSustitucion = true;

        fechaEntrega = null;
        horaEntrega = null;
      });

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Expanded(child: Text('¡Solicitud enviada!')),
              ],
            ),
            content: const Text(
              'Tu solicitud de arreglo personalizado fue enviada correctamente. '
              'La florería podrá revisar tus preferencias y preparar una propuesta.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la solicitud: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Personalizar arreglo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // =================================================
          // ENCABEZADO
          // =================================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.12),
                  Colors.pink.withOpacity(0.07),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_florist, color: Colors.purple, size: 42),

                SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diseña tu arreglo ideal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Cuéntanos el estilo que buscas y la florista elegirá flores adecuadas según disponibilidad.',
                        style: TextStyle(color: Colors.grey, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =================================================
          // TIPO DE ARREGLO
          // =================================================
          _tituloSeccion('Tipo de arreglo'),

          const SizedBox(height: 8),

          _dropdown(
            valor: tipoArreglo,
            items: tiposArreglo,
            icono: Icons.local_florist_outlined,
            onChanged: (valor) {
              setState(() {
                tipoArreglo = valor!;
              });
            },
          ),

          const SizedBox(height: 20),

          // =================================================
          // ESTILO
          // =================================================
          _tituloSeccion('Estilo'),

          const SizedBox(height: 8),

          _dropdown(
            valor: estiloSeleccionado,
            items: estilos,
            icono: Icons.auto_awesome_outlined,
            onChanged: (valor) {
              setState(() {
                estiloSeleccionado = valor!;
              });
            },
          ),

          const SizedBox(height: 20),

          // =================================================
          // COLORES
          // =================================================
          _tituloSeccion('Colores predominantes'),

          const SizedBox(height: 8),

          _dropdown(
            valor: coloresSeleccionados,
            items: opcionesColores,
            icono: Icons.palette_outlined,
            onChanged: (valor) {
              setState(() {
                coloresSeleccionados = valor!;
              });
            },
          ),

          const SizedBox(height: 20),

          // =================================================
          // TAMAÑO
          // =================================================
          _tituloSeccion('Tamaño'),

          const SizedBox(height: 8),

          _dropdown(
            valor: tamanoSeleccionado,
            items: tamanos,
            icono: Icons.aspect_ratio,
            onChanged: (valor) {
              setState(() {
                tamanoSeleccionado = valor!;
              });
            },
          ),

          const SizedBox(height: 20),

          // =================================================
          // OCASIÓN
          // =================================================
          _tituloSeccion('Ocasión'),

          const SizedBox(height: 8),

          _dropdown(
            valor: ocasionSeleccionada,
            items: ocasiones,
            icono: Icons.card_giftcard_outlined,
            onChanged: (valor) {
              setState(() {
                ocasionSeleccionada = valor!;
              });
            },
          ),

          const SizedBox(height: 20),

          // =================================================
          // PRESUPUESTO
          // =================================================
          _tituloSeccion('Presupuesto aproximado'),

          const SizedBox(height: 8),

          TextField(
            controller: presupuestoController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              'Ej. 800',
              Icons.payments_outlined,
              prefixText: '\$ ',
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'La florista tomará este presupuesto como referencia.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // =================================================
          // FLORES DESEADAS
          // =================================================
          _tituloSeccion('Flores que te gustaría incluir'),

          const SizedBox(height: 8),

          TextField(
            controller: floresDeseadasController,
            decoration: _inputDecoration(
              'Ej. rosas, tulipanes, margaritas...',
              Icons.local_florist_outlined,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Opcional. Puedes dejarlo vacío y permitir que la florista elija.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // =================================================
          // FLORES NO DESEADAS
          // =================================================
          _tituloSeccion('Flores que no quieres'),

          const SizedBox(height: 8),

          TextField(
            controller: floresNoDeseadasController,
            decoration: _inputDecoration(
              'Ej. no quiero girasoles',
              Icons.block_outlined,
            ),
          ),

          const SizedBox(height: 20),

          // =================================================
          // SUSTITUCIÓN
          // =================================================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.withOpacity(0.10)),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: permiteSustitucion,
              activeColor: Colors.purple,

              title: const Text(
                'Permitir sustituciones',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: const Text(
                'Si alguna flor no está disponible, la florista puede sustituirla respetando el estilo y los colores.',
              ),

              onChanged: (valor) {
                setState(() {
                  permiteSustitucion = valor;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // =================================================
          // MENSAJE TARJETA
          // =================================================
          _tituloSeccion('Mensaje para tarjeta'),

          const SizedBox(height: 8),

          TextField(
            controller: mensajeTarjetaController,
            maxLines: 2,
            maxLength: 120,
            decoration: _inputDecoration(
              'Ej. Feliz aniversario, te amo',
              Icons.mail_outline,
            ),
          ),

          const SizedBox(height: 12),

          // =================================================
          // DESCRIPCIÓN
          // =================================================
          _tituloSeccion('¿Cómo imaginas tu arreglo?'),

          const SizedBox(height: 8),

          TextField(
            controller: descripcionController,
            maxLines: 4,
            decoration: _inputDecoration(
              'Ej. Quiero algo delicado, elegante, con tonos claros y no muy cargado.',
              Icons.edit_note_outlined,
            ),
          ),

          const SizedBox(height: 25),

          // =================================================
          // FECHA Y HORA
          // =================================================
          _tituloSeccion('Entrega'),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _selectorFecha(context)),

              const SizedBox(width: 10),

              Expanded(child: _selectorHora(context)),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            'Horario de entrega: 8:00 AM a 9:00 PM.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 30),

          // =================================================
          // BOTÓN
          // =================================================
          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              onPressed: enviando ? null : solicitarArreglo,

              icon: enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),

              label: Text(
                enviando ? 'ENVIANDO...' : 'ENVIAR SOLICITUD',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // =========================================================
  // TÍTULO
  // =========================================================

  Widget _tituloSeccion(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xff2D1B33),
      ),
    );
  }

  // =========================================================
  // DROPDOWN
  // =========================================================

  Widget _dropdown({
    required String valor,
    required List<String> items,
    required IconData icono,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: valor,
      isExpanded: true,

      decoration: InputDecoration(
        prefixIcon: Icon(icono, color: Colors.purple),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purple),
        ),
      ),

      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),

      onChanged: onChanged,
    );
  }

  // =========================================================
  // DECORACIÓN DE TEXTFIELD
  // =========================================================

  InputDecoration _inputDecoration(
    String hint,
    IconData icono, {
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixText: prefixText,

      prefixIcon: Icon(icono, color: Colors.purple),

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.purple),
      ),
    );
  }

  // =========================================================
  // SELECTOR FECHA
  // =========================================================

  Widget _selectorFecha(BuildContext context) {
    return InkWell(
      onTap: seleccionarFecha,

      borderRadius: BorderRadius.circular(15),

      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.purple),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                fechaEntrega == null
                    ? 'Fecha'
                    : '${fechaEntrega!.day}/${fechaEntrega!.month}/${fechaEntrega!.year}',
                style: TextStyle(
                  color: fechaEntrega == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SELECTOR HORA
  // =========================================================

  Widget _selectorHora(BuildContext context) {
    return InkWell(
      onTap: seleccionarHora,

      borderRadius: BorderRadius.circular(15),

      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.purple),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                horaEntrega == null ? 'Hora' : horaEntrega!.format(context),
                style: TextStyle(
                  color: horaEntrega == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
