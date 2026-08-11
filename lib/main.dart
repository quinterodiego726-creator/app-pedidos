import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/producto.dart';
import 'package:flutter_application_1/models/item_carrito.dart';
import 'package:flutter_application_1/views/home_view.dart';
import 'package:flutter_application_1/views/login_view.dart';

void main() {
  runApp(const MiAppRestaurante());
}

class MiAppRestaurante extends StatefulWidget {
  const MiAppRestaurante({super.key});

  @override
  State<MiAppRestaurante> createState() => _MiAppRestauranteState();
}

class _MiAppRestauranteState extends State<MiAppRestaurante> {
  bool estaAutenticado = false;
  final List<ItemCarrito> carrito = [];

  final List<Producto> catalogo = [
    Producto(
      id: '1',
      nombre: 'Hamburguesa Súper',
      precio: 20900,
      descripcion:
          'Carne artesanal de 150g, queso cheddar, tocineta crujiente, vegetales frescos y salsa de la casa.',
      icono: Icons.lunch_dining,
      categoria: 'Hamburguesas',
    ),
    Producto(
      id: '2',
      nombre: 'Pizza Personal Especial',
      precio: 22900,
      descripcion:
          'Masa delgada artesanal, salsa pomodoro, queso mozzarella premium, pepperoni y albahaca fresca.',
      icono: Icons.local_pizza,
      categoria: 'Pizzas',
    ),
    Producto(
      id: '3',
      nombre: 'Papas Nativas Supremas',
      precio: 15500,
      descripcion:
          'Papas rústicas acompañadas de una salsa de queso fundido, trozos de tocineta.',
      icono: Icons.local_drink,
      categoria: 'Acompañamientos',
    ),
    Producto(
      id: '4',
      nombre: 'Malteada',
      precio: 9500,
      descripcion:
          'Helado cremoso de vainilla, crema batida y un toque de salsa de chocolate.',
      icono: Icons.local_cafe,
      categoria: 'Bebidas',
    ),
  ];

  // Agrega un producto o incrementa su cantidad si ya existe
  void agregarAlCarrito(Producto producto) {
    setState(() {
      final index = carrito.indexWhere(
        (item) => item.producto.id == producto.id,
      );
      if (index != -1) {
        carrito[index].cantidad++;
      } else {
        carrito.add(ItemCarrito(producto: producto));
      }
    });
  }

  // Modifica la cantidad de un producto (+1 o -1)
  void cambiarCantidad(ItemCarrito item, int cambio) {
    setState(() {
      item.cantidad += cambio;
      if (item.cantidad <= 0) {
        carrito.remove(item);
      }
    });
  }

  // Elimina un ítem directamente del carrito
  void eliminarDelCarrito(ItemCarrito item) {
    setState(() {
      carrito.remove(item);
    });
  }

  void limpiarCarrito() {
    setState(() {
      carrito.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos Diego',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(0, 239, 127, 1),
          primary: const Color.fromARGB(255, 0, 239, 16),
          secondary: const Color.fromARGB(255, 64, 255, 115),
        ),
        useMaterial3: true,
      ),
      home: estaAutenticado
          ? HomeView(
              catalogo: catalogo,
              carrito: carrito,
              onAgregar: agregarAlCarrito,
              onCambiarCantidad: cambiarCantidad,
              onEliminar: eliminarDelCarrito,
              onLimpiarCarrito: limpiarCarrito,
            )
          : LoginView(
              onLoginExitoso: () {
                setState(() {
                  estaAutenticado = true;
                });
              },
            ),
    );
  }
}
