import 'partida.dart';
import 'tipo_cliente.dart';

enum EstadoPedido { pendiente, confirmado, rechazado }

class Pedido {
  final String id;
  final List<Partida> partidas;
  final TipoCliente tipoCliente;
  EstadoPedido estado;

  /// Total fijado al confirmar. El corte del día suma este valor en vez de
  /// recalcular, para que un cambio posterior en la promoción no altere lo
  /// que ya se cobró.
  double? totalCobrado;

  Pedido({
    required this.id,
    required this.partidas,
    required this.tipoCliente,
    this.estado = EstadoPedido.pendiente,
  });
}
