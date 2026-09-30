import '../models/partida.dart';
import '../models/tipo_cliente.dart';
import 'pricing/calculadora_precio.dart';
import 'promocion_service.dart';

/// Arma el pedido en el mostrador o desde el teléfono del cliente y muestra
/// el subtotal en vivo mientras se agregan partidas.
class CarritoService {
  final List<Partida> _partidas = [];
  final CalculadoraPrecio _calculadoraPrecio = CalculadoraPrecio();

  List<Partida> get partidas => List.unmodifiable(_partidas);

  void agregar(Partida partida) => _partidas.add(partida);

  void quitar(Partida partida) => _partidas.remove(partida);

  double calcularSubtotalPartida(Partida partida, TipoCliente tipoCliente) {
    return _calculadoraPrecio.calcularPrecioPartida(
      partida,
      tipoCliente,
      promocionActiva: PromocionService.temporadaActiva,
    );
  }

  double calcularTotal(TipoCliente tipoCliente) {
    return _partidas.fold(
      0.0,
      (total, partida) => total + calcularSubtotalPartida(partida, tipoCliente),
    );
  }
}
