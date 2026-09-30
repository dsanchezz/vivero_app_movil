import '../models/partida.dart';
import '../models/planta.dart';
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

  void vaciar() => _partidas.clear();

  int cantidadDe(Planta planta) {
    for (final partida in _partidas) {
      if (partida.planta.id == planta.id) return partida.cantidad;
    }
    return 0;
  }

  /// Deja una sola partida de [planta] con [cantidad]; con 0 la quita.
  void cambiarCantidad(Planta planta, int cantidad) {
    final indice = _partidas.indexWhere((p) => p.planta.id == planta.id);
    if (indice == -1) {
      if (cantidad > 0) agregar(Partida(planta: planta, cantidad: cantidad));
    } else if (cantidad > 0) {
      _partidas[indice] = Partida(planta: planta, cantidad: cantidad);
    } else {
      quitar(_partidas[indice]);
    }
  }

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
