import '../models/pedido.dart';
import 'pricing/calculadora_precio.dart';
import 'promocion_service.dart';

/// Guarda los pedidos y resuelve las acciones de la encargada
/// (confirmar/rechazar, corte del día). El total se recalcula aquí en vez de
/// confiar en el total que trae el carrito, porque hoy no hay servidor que
/// arbitre esa verdad.
class PedidoService {
  final List<Pedido> _pedidos = [];
  final CalculadoraPrecio _calculadoraPrecio = CalculadoraPrecio();

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  void registrar(Pedido pedido) => _pedidos.add(pedido);

  double calcularTotalPedido(Pedido pedido) {
    final promocionActiva = PromocionService.temporadaActiva;

    return pedido.partidas.fold(0.0, (total, partida) {
      return total +
          _calculadoraPrecio.calcularPrecioPartida(
            partida,
            pedido.tipoCliente,
            promocionActiva: promocionActiva,
          );
    });
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
