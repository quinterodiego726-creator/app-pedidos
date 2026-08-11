import 'package:flutter_application_1/models/producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({
    required this.producto,
    this.cantidad = 1,
  });

  int get subtotal => producto.precio * cantidad;
}