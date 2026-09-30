import '../models/pedido.dart';
import '../models/tipo_cliente.dart';
import 'promocion_service.dart';

/// Guarda los pedidos y resuelve las acciones de la encargada
/// (confirmar/rechazar, corte del día). El total se recalcula aquí en vez de
/// confiar en el total que trae el carrito, porque hoy no hay servidor que
/// arbitre esa verdad.
class PedidoService {
  final List<Pedido> _pedidos = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  void registrar(Pedido pedido) => _pedidos.add(pedido);

  double calcularTotalPedido(Pedido pedido) {
    final promocionActiva = PromocionService.temporadaActiva;
    double total = 0;

    for (final partida in pedido.partidas) {
      double precioUnitario;

      if (pedido.tipoCliente == TipoCliente.mayorista) {
        if (partida.cantidad >= 10) {
          precioUnitario = partida.planta.precioBase * 0.80;
        } else {
          precioUnitario = partida.planta.precioBase * 0.90;
        }
        if (promocionActiva) {
          precioUnitario = precioUnitario * 0.95;
        }
      } else {
        if (promocionActiva) {
          precioUnitario = partida.planta.precioBase * 0.85;
        } else {
          precioUnitario = partida.planta.precioBase;
        }
      }

      total += precioUnitario * partida.cantidad;
    }

    return total;
  }

  Pedido confirmar(Pedido pedido) {
    pedido.estado = EstadoPedido.confirmado;
    return pedido;
  }

  Pedido rechazar(Pedido pedido) {
    pedido.estado = EstadoPedido.rechazado;
    return pedido;
  }

  double corteDelDia() {
    return _pedidos
        .where((p) => p.estado == EstadoPedido.confirmado)
        .fold(0.0, (total, pedido) => total + calcularTotalPedido(pedido));
  }
}
