import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/models/producto.dart';
import 'package:flutter_application_1/models/item_carrito.dart';

class HomeView extends StatefulWidget {
  final List<Producto> catalogo;
  final List<ItemCarrito> carrito;
  final void Function(Producto) onAgregar;
  final void Function(ItemCarrito, int) onCambiarCantidad;
  final void Function(ItemCarrito) onEliminar;
  final VoidCallback onLimpiarCarrito;

  const HomeView({
    super.key,
    required this.catalogo,
    required this.carrito,
    required this.onAgregar,
    required this.onCambiarCantidad,
    required this.onEliminar,
    required this.onLimpiarCarrito,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String categoriaSeleccionada = 'Todos';
  String textoBusqueda = '';
  String metodoPagoSeleccionado = 'Efectivo / Contra Entrega';

  //  Control de estado del pedido (0: Sin orden, 1: Recibido, 2: En preparación, 3: En camino, 4: Entregado)
  int pasoEstadoPedido = 0;

  int get totalPedido {
    return widget.carrito.fold(0, (sum, item) => sum + item.subtotal);
  }

  // : Función para lanzar chat de soporte en WhatsApp
  Future<void> _abrirWhatsApp() async {
    const numeroTelefono = '3206570609'; 
    const mensaje =
        'Hola, necesito ayuda con mi pedido en la app Pedidos Diego.';
    final Uri url = Uri.parse(
      'https://wa.me/$numeroTelefono?text=${Uri.encodeComponent(mensaje)}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  void _procesarPago(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirmar Pedido'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona el método de pago:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Efectivo / Contra Entrega'),
                    value: 'Efectivo / Contra Entrega',
                    groupValue: metodoPagoSeleccionado,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          metodoPagoSeleccionado = value;
                        });
                        setState(() {
                          metodoPagoSeleccionado = value;
                        });
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Pago Digital (Transferencia/Nequi)'),
                    value: 'Pago Digital',
                    groupValue: metodoPagoSeleccionado,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          metodoPagoSeleccionado = value;
                        });
                        setState(() {
                          metodoPagoSeleccionado = value;
                        });
                      }
                    },
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total a pagar:'),
                      Text(
                        '\$$totalPedido',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _mostrarReciboConfirmacion(context);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarReciboConfirmacion(BuildContext context) {
    final resumenTotal = totalPedido;
    final resumenMetodo = metodoPagoSeleccionado;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
          title: const Text('¡Pedido Confirmado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tu orden ha sido registrada correctamente.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Método de pago:'),
                        Text(
                          resumenMetodo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total abonado:'),
                        Text(
                          '\$$resumenTotal',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
               setState(() {
                  pasoEstadoPedido = 1; // Inicia el rastreo
                  widget.onLimpiarCarrito();
                });
                Navigator.pop(context);
                DefaultTabController.of(context).animateTo(2);
              },
              child: const Text('Ver Estado del Pedido'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetalleProducto(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: const EdgeInsets.all(20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  producto.icono,
                  size: 70,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                producto.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  producto.categoria,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 12),
              Text(
                producto.descripcion,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Text(
                '\$${producto.precio}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                widget.onAgregar(producto);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${producto.nombre} agregado!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = [
      'Todos',
      ...{for (var p in widget.catalogo) p.categoria},
    ];

    final productosFiltrados = widget.catalogo.where((p) {
      final coincideCategoria =
          categoriaSeleccionada == 'Todos' ||
          p.categoria == categoriaSeleccionada;
      final coincideBusqueda =
          p.nombre.toLowerCase().contains(textoBusqueda.toLowerCase()) ||
          p.descripcion.toLowerCase().contains(textoBusqueda.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();

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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _abrirWhatsApp,
          icon: const Icon(Icons.chat),
          label: const Text('Soporte'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: TabBarView(
          children: [
            // PESTAÑA MENÚ
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: TextField(
                    onChanged: (value) => setState(() => textoBusqueda = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: textoBusqueda.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => textoBusqueda = ''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categorias.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final cat = categorias[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: categoriaSeleccionada == cat,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => categoriaSeleccionada = cat);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: productosFiltrados.isEmpty
                      ? const Center(child: Text('No se encontraron productos'))
                      : ListView.builder(
                          itemCount: productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = productosFiltrados[index];
                            return ListTile(
                              onTap: () =>
                                  _mostrarDetalleProducto(context, producto),
                              leading: Icon(producto.icono, size: 30),
                              title: Text(producto.nombre),
                              subtitle: Text(
                                '\$${producto.precio} - ${producto.descripcion}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  widget.onAgregar(producto);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${producto.nombre} agregado!',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text('Agregar'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // PESTAÑA CARRITO
            widget.carrito.isEmpty
                ? const Center(child: Text('El carrito está vacío'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.carrito.length,
                          itemBuilder: (context, index) {
                            final item = widget.carrito[index];
                            return ListTile(
                              leading: Icon(item.producto.icono, size: 30),
                              title: Text(item.producto.nombre),
                              subtitle: Text(
                                '\$${item.producto.precio} x ${item.cantidad} = \$${item.subtotal}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        widget.onCambiarCantidad(item, -1),
                                  ),
                                  Text(
                                    '${item.cantidad}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                    ),
                                    onPressed: () =>
                                        widget.onCambiarCantidad(item, 1),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => widget.onEliminar(item),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: const Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total del Pedido:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$$totalPedido',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: widget.onLimpiarCarrito,
                                  icon: const Icon(
                                    Icons.delete_sweep,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Vaciar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _procesarPago(context),
                                    icon: const Icon(Icons.payment),
                                    label: const Text('Confirmar Pedido'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

            // PESTAÑA SEGUIMIENTO DE PEDIDO (RF12)
            pasoEstadoPedido == 0
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          color: Colors.grey,
                          size: 80,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tienes pedidos activos',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado de tu Orden',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Stepper(
                            physics: const NeverScrollableScrollPhysics(),
                            currentStep: pasoEstadoPedido - 1,
                            onStepTapped: (step) {
                              setState(() {
                                pasoEstadoPedido = step + 1;
                              });
                            },
                            controlsBuilder: (context, details) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    if (pasoEstadoPedido < 4)
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            pasoEstadoPedido++;
                                          });
                                        },
                                        child: const Text('Avanzar Estado'),
                                      ),
                                  ],
                                ),
                              );
                            },
                            steps: [
                              Step(
                                title: const Text('Pedido Recibido'),
                                subtitle: const Text(
                                  'Hemos recibido tu orden.',
                                ),
                                content: const SizedBox.shrink(),
                                isActive: pasoEstadoPedido >= 1,
                                state: pasoEstadoPedido > 1
                                    ? StepState.complete
                                    : StepState.editing,
                              ),
                              Step(
                                title: const Text('En Preparación'),
                                subtitle: const Text(
                                  'La cocina está preparando tus alimentos.',
                                ),
                                content: const SizedBox.shrink(),
                                isActive: pasoEstadoPedido >= 2,
                                state: pasoEstadoPedido > 2
                                    ? StepState.complete
                                    : StepState.editing,
                              ),
                              Step(
                                title: const Text('En Camino'),
                                subtitle: const Text(
                                  'El domiciliario lleva tu pedido.',
                                ),
                                content: const SizedBox.shrink(),
                                isActive: pasoEstadoPedido >= 3,
                                state: pasoEstadoPedido > 3
                                    ? StepState.complete
                                    : StepState.editing,
                              ),
                              Step(
                                title: const Text('Entregado'),
                                subtitle: const Text('¡Disfruta tu comida!'),
                                content: const SizedBox.shrink(),
                                isActive: pasoEstadoPedido == 4,
                                state: pasoEstadoPedido == 4
                                    ? StepState.complete
                                    : StepState.indexed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
