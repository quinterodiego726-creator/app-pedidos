import 'package:flutter/material.dart';

class Producto {
  final String id;
  final String nombre;
  final int precio;
  final String descripcion;
  final IconData icono;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.icono,
    required this.categoria,
  });
}
