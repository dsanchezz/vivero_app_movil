import 'partida.dart';
import 'tipo_cliente.dart';

enum EstadoPedido { pendiente, confirmado, rechazado }

class Pedido {
  final String id;
  final List<Partida> partidas;
  final TipoCliente tipoCliente;
  EstadoPedido estado;

  Pedido({
    required this.id,
    required this.partidas,
    required this.tipoCliente,
    this.estado = EstadoPedido.pendiente,
  });
}
