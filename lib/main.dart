import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';

import 'package:provider/provider.dart';
import 'carrito/carrito_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => CarritoProvider(),

      child: const FloreriaApp(),
    ),
  );
}

class FloreriaApp extends StatelessWidget {
  const FloreriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Florería Ámbar',

      theme: ThemeData(primarySwatch: Colors.purple),

      home: const LoginScreen(),
    );
  }
}
