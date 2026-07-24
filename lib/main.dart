import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/producto.dart';
import 'package:flutter_application_1/views/home_view.dart';

void main() {
  runApp(const MiAppRestaurante());
}

class MiAppRestaurante extends StatefulWidget {
  const MiAppRestaurante({super.key});

  @override
  State<MiAppRestaurante> createState() => _MiAppRestauranteState();
}

class _MiAppRestauranteState extends State<MiAppRestaurante> {
  final List<Producto> carrito = [];

  final List<Producto> catalogo = [
    Producto(
      id: '1',
      nombre: 'Hamburguesa Súper',
      precio: 20900,
      descripcion:
          'Carne artesanal de 150g, queso cheddar, tocineta crujiente, vegetales frescos y salsa de la casa.',
      icono: Icons.lunch_dining,
    ),
    Producto(
      id: '2',
      nombre: 'Pizza Personal Especial',
      precio: 22900,
      descripcion:
          'Masa delgada artesanal, salsa pomodoro, queso mozzarella premium, pepperoni y albahaca fresca.',
      icono: Icons.local_pizza,
    ),
    Producto(
      id: '3',
      nombre: 'Papas Nativas Supremas',
      precio: 15500,
      descripcion:
          'Papas rústicas acompañadas de una salsa de queso fundido, trozos de tocineta.',
      icono: Icons.local_drink,
    ),
    Producto(
      id: '4',
      nombre: 'Malteada',
      precio: 9500,
      descripcion:
          'Helado cremoso de vainilla, crema batida y un toque de salsa de chocolate.',
      icono: Icons.local_cafe,
    ),
  ];

  void agregarAlCarrito(Producto producto) {
    setState(() {
      carrito.add(producto);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado al carrito'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void limpiarCarrito() {
    setState(() {
      carrito.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' Pedidos  Diego',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(0, 239, 127, 1),
          primary: const Color.fromARGB(255, 0, 239, 16),
          secondary: const Color.fromARGB(255, 64, 255, 115),
        ),
        useMaterial3: true,
      ),
      home: HomeView(
        catalogo: catalogo,
        carrito: carrito,
        onAgregar: agregarAlCarrito,
        onLimpiarCarrito: limpiarCarrito,
      ),
    );
  }
}
