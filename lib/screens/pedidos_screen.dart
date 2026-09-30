import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../services/promocion_service.dart';
import 'formato.dart';

/// Vista de la encargada: activa la promoción de temporada, confirma o
/// rechaza pedidos y consulta el corte del día.
class PedidosScreen extends StatelessWidget {
  const PedidosScreen({
    super.key,
    required this.pedidos,
    required this.onCambio,
  });

  final PedidoService pedidos;
  final VoidCallback onCambio;

  @override
  Widget build(BuildContext context) {
    final lista = pedidos.pedidos.reversed.toList();
    final confirmados = lista
        .where((p) => p.estado == EstadoPedido.confirmado)
        .length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        SwitchListTile(
          title: const Text('Promoción de temporada'),
          subtitle: const Text('General 15% · Mayorista 5% adicional'),
          value: PromocionService.temporadaActiva,
          onChanged: (activa) {
            PromocionService.temporadaActiva = activa;
            onCambio();
          },
        ),
        ListTile(
          leading: const Icon(Icons.point_of_sale),
          title: const Text('Corte del día'),
          subtitle: Text('$confirmados pedidos confirmados'),
          trailing: Text(
            formatoPrecio(pedidos.corteDelDia()),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const Divider(),
        if (lista.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('Aún no hay pedidos', textAlign: TextAlign.center),
          ),
        for (final pedido in lista) _tarjetaPedido(context, pedido),
      ],
    );
  }

  Widget _tarjetaPedido(BuildContext context, Pedido pedido) {
    final pendiente = pedido.estado == EstadoPedido.pendiente;
    final total = pedido.estado == EstadoPedido.confirmado
        ? 'Cobrado: ${formatoPrecio(pedido.totalCobrado!)}'
        : 'Total: ${formatoPrecio(pedidos.calcularTotalPedido(pedido))}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${pedido.id} · ${nombreTipoCliente(pedido.tipoCliente)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(nombreEstado(pedido.estado)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              pedido.partidas
                  .map((p) => '${p.cantidad} × ${p.planta.nombre}')
                  .join(', '),
            ),
            const SizedBox(height: 4),
            Text(total),
            if (pendiente)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      pedidos.rechazar(pedido);
                      onCambio();
                    },
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      pedidos.confirmar(pedido);
                      onCambio();
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
