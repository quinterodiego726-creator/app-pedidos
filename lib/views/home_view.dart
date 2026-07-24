import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/producto.dart';

class HomeView extends StatefulWidget {
  final List<Producto> catalogo;
  final List<Producto> carrito;
  final Function(Producto) onAgregar;
  final VoidCallback onLimpiarCarrito;

  const HomeView({
    super.key,
    required this.catalogo,
    required this.carrito,
    required this.onAgregar,
    required this.onLimpiarCarrito,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pedidos Diego'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flatware), text: 'Menú'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Carrito'),
              Tab(icon: Icon(Icons.assignment), text: 'Estado'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            
            ListView.builder(
              itemCount: widget.catalogo.length,
              itemBuilder: (context, index) {
                final producto = widget.catalogo[index];
                return ListTile(
                  leading: Icon(producto.icono, size: 30),
                  title: Text(producto.nombre),
                  subtitle: Text(
                    '\$${producto.precio} - ${producto.descripcion}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.onAgregar(producto);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${producto.nombre} agregado!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text('Agregar'),
                  ),
                );
              },
            ),
            
            widget.carrito.isEmpty
                ? const Center(child: Text('El carrito está vacío'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.carrito.length,
                          itemBuilder: (context, index) {
                            final producto = widget.carrito[index];
                            return ListTile(
                              leading: Icon(producto.icono, size: 30),
                              title: Text(producto.nombre),
                              subtitle: Text('\$${producto.precio}'),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              widget.onLimpiarCarrito();
                            });
                          },
                          icon: const Icon(Icons.delete_sweep),
                          label: const Text('Limpiar Carrito'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
            
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 16),
                  Text(
                    'Tu orden está siendo preparada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
