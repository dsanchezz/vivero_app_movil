import 'package:flutter/material.dart';

import 'models/pedido.dart';
import 'screens/catalogo_screen.dart';
import 'screens/pedidos_screen.dart';
import 'services/carrito_service.dart';
import 'services/pedido_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vivero Xochicalco',
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const InicioScreen(),
    );
  }
}

/// Contenedor con las dos vistas de la app. Los servicios viven aquí para que
/// catálogo y pedidos compartan el mismo estado mientras no hay servidor.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final CarritoService _carrito = CarritoService();
  final PedidoService _pedidos = PedidoService();
  int _pestana = 0;

  void _refrescar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pendientes = _pedidos.pedidos
        .where((p) => p.estado == EstadoPedido.pendiente)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Vivero Xochicalco')),
      body: IndexedStack(
        index: _pestana,
        children: [
          CatalogoScreen(
            carrito: _carrito,
            pedidos: _pedidos,
            onCambio: _refrescar,
          ),
          PedidosScreen(pedidos: _pedidos, onCambio: _refrescar),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.local_florist),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendientes > 0,
              label: Text('$pendientes'),
              child: const Icon(Icons.receipt_long),
            ),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}
