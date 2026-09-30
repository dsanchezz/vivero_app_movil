import 'package:flutter/material.dart';

import '../data/catalogo_local.dart';
import '../models/partida.dart';
import '../models/planta.dart';
import '../models/tipo_cliente.dart';
import '../services/carrito_service.dart';
import '../services/pedido_service.dart';
import '../services/promocion_service.dart';
import 'formato.dart';

/// Catálogo del cliente o del mostrador: se elige el tipo de cliente, se arman
/// las partidas con su subtotal en vivo y se envía el pedido a la encargada.
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({
    super.key,
    required this.carrito,
    required this.pedidos,
    required this.onCambio,
  });

  final CarritoService carrito;
  final PedidoService pedidos;
  final VoidCallback onCambio;

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  TipoCliente _tipoCliente = TipoCliente.general;

  void _cambiarCantidad(Planta planta, int cantidad) {
    widget.carrito.cambiarCantidad(planta, cantidad);
    widget.onCambio();
  }

  void _enviarPedido() {
    final pedido = widget.pedidos.crearPedido(
      widget.carrito.partidas,
      _tipoCliente,
    );
    widget.carrito.vaciar();
    widget.onCambio();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pedido ${pedido.id} enviado a la encargada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = widget.carrito;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<TipoCliente>(
            segments: [
              for (final tipo in TipoCliente.values)
                ButtonSegment(
                  value: tipo,
                  label: Text(nombreTipoCliente(tipo)),
                ),
            ],
            selected: {_tipoCliente},
            onSelectionChanged: (seleccion) =>
                setState(() => _tipoCliente = seleccion.first),
          ),
        ),
        if (PromocionService.temporadaActiva)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Chip(
              avatar: Icon(Icons.local_offer, size: 18),
              label: Text('Promoción de temporada activa'),
            ),
          ),
        Expanded(
          child: ListView(
            children: [
              for (final planta in CatalogoLocal.plantas) _filaPlanta(planta),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total: ${formatoPrecio(carrito.calcularTotal(_tipoCliente))}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton(
                onPressed: carrito.partidas.isEmpty ? null : _enviarPedido,
                child: const Text('Enviar pedido'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filaPlanta(Planta planta) {
    final cantidad = widget.carrito.cantidadDe(planta);
    final subtotal = widget.carrito.calcularSubtotalPartida(
      Partida(planta: planta, cantidad: cantidad),
      _tipoCliente,
    );

    return ListTile(
      title: Text(planta.nombre),
      subtitle: Text(
        '${formatoPrecio(planta.precioBase)} c/u · Existencia: ${planta.existencia}'
        '${cantidad > 0 ? '\nSubtotal: ${formatoPrecio(subtotal)}' : ''}',
      ),
      isThreeLine: cantidad > 0,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: cantidad > 0
                ? () => _cambiarCantidad(planta, cantidad - 1)
                : null,
          ),
          SizedBox(
            width: 24,
            child: Text('$cantidad', textAlign: TextAlign.center),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: cantidad < planta.existencia
                ? () => _cambiarCantidad(planta, cantidad + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
