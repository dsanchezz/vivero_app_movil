import 'package:flutter/material.dart';

import 'data/catalogo_local.dart';
import 'models/partida.dart';
import 'models/tipo_cliente.dart';
import 'services/carrito_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vivero Xochicalco',
      home: CatalogoScreen(),
    );
  }
}

/// Pantalla de catálogo del cliente: precio y disponibilidad por planta,
/// usando datos locales mientras no hay servidor disponible.
class CatalogoScreen extends StatelessWidget {
  CatalogoScreen({super.key});

  final CarritoService _carrito = CarritoService();

  @override
  Widget build(BuildContext context) {
    final partidas = CatalogoLocal.plantas
        .map((planta) => Partida(planta: planta, cantidad: 3))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Vivero Xochicalco')),
      body: ListView.builder(
        itemCount: partidas.length,
        itemBuilder: (context, index) {
          final partida = partidas[index];
          final subtotal = _carrito.calcularSubtotalPartida(
            partida,
            TipoCliente.general,
          );
          return ListTile(
            title: Text(partida.planta.nombre),
            subtitle: Text('Existencia: ${partida.planta.existencia}'),
            trailing: Text('\$${subtotal.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
