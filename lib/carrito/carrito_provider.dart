import 'package:flutter/material.dart';

class CarritoProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _productos = [];

  List<Map<String, dynamic>> get productos => _productos;

  void agregarProducto(Map<String, dynamic> producto) {
    _productos.add(Map<String, dynamic>.from(producto));
    notifyListeners();
  }

  void eliminarProducto(int index) {
    if (index >= 0 && index < _productos.length) {
      _productos.removeAt(index);
      notifyListeners();
    }
  }

  void vaciarCarrito() {
    _productos.clear();
    notifyListeners();
  }

  double get total {
    double suma = 0;

    for (final producto in _productos) {
      suma += (producto['precio'] as num).toDouble();
    }

    return suma;
  }
}
