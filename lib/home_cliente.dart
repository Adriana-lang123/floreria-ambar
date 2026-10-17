import 'package:flutter/material.dart';

import 'inicio.dart';
import 'menu.dart';
import 'carrito.dart';
import 'perfil.dart';

class HomeCliente extends StatelessWidget {
  const HomeCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeClienteBody();
  }
}

class HomeClienteBody extends StatefulWidget {
  const HomeClienteBody({super.key});

  @override
  State<HomeClienteBody> createState() => _HomeClienteBodyState();
}

class _HomeClienteBodyState extends State<HomeClienteBody> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    InicioScreen(),
    MenuScreen(),
    CarritoScreen(),
    PerfilScreen(),
  ];

  final List<IconData> iconos = const [
    Icons.home_rounded,
    Icons.local_florist_rounded,
    Icons.shopping_bag_rounded,
    Icons.person_rounded,
  ];

  final List<String> titulos = const [
    'Inicio',
    'Personalizar',
    'Carrito',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FC),

      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: List.generate(screens.length, (index) {
              final bool seleccionado = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                    });
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),

                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),

                    decoration: BoxDecoration(
                      color: seleccionado
                          ? Colors.purple.withOpacity(0.10)
                          : Colors.transparent,

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),

                          width: 42,
                          height: 42,

                          decoration: BoxDecoration(
                            color: seleccionado
                                ? Colors.purple
                                : Colors.transparent,

                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            iconos[index],

                            color: seleccionado
                                ? Colors.white
                                : Colors.grey.shade500,

                            size: 23,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          titulos[index],

                          maxLines: 1,

                          style: TextStyle(
                            fontSize: 11,

                            fontWeight: seleccionado
                                ? FontWeight.bold
                                : FontWeight.w500,

                            color: seleccionado
                                ? Colors.purple
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
