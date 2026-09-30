import '../../models/partida.dart';
import '../../models/tipo_cliente.dart';
import 'estrategia_precio.dart';
import 'precio_general_strategy.dart';
import 'precio_mayorista_strategy.dart';

/// Contexto del Strategy: única fuente de verdad para el precio de una
/// partida. CarritoService y PedidoService la consultan en vez de repetir
/// la decisión por tipo de cliente y promoción.
class CalculadoraPrecio {
  static final Map<TipoCliente, EstrategiaPrecio> _estrategias = {
    TipoCliente.general: PrecioGeneralStrategy(),
    TipoCliente.mayorista: PrecioMayoristaStrategy(),
  };

  double calcularPrecioPartida(
    Partida partida,
    TipoCliente tipoCliente, {
    required bool promocionActiva,
  }) {
    final estrategia = _estrategias[tipoCliente]!;
    final precioUnitario = estrategia.precioUnitario(
      precioBase: partida.planta.precioBase,
      cantidad: partida.cantidad,
      promocionActiva: promocionActiva,
    );
    return precioUnitario * partida.cantidad;
  }
}
