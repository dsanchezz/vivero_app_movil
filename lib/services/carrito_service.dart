import '../models/partida.dart';
import '../models/tipo_cliente.dart';
import 'promocion_service.dart';

/// Arma el pedido en el mostrador o desde el teléfono del cliente y muestra
/// el subtotal en vivo mientras se agregan partidas.
class CarritoService {
  final List<Partida> _partidas = [];

  List<Partida> get partidas => List.unmodifiable(_partidas);

  void agregar(Partida partida) => _partidas.add(partida);

  void quitar(Partida partida) => _partidas.remove(partida);

  double calcularSubtotalPartida(Partida partida, TipoCliente tipoCliente) {
    final promocionActiva = PromocionService.temporadaActiva;
    double precioUnitario;

    if (tipoCliente == TipoCliente.mayorista) {
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

    return precioUnitario * partida.cantidad;
  }

  double calcularTotal(TipoCliente tipoCliente) {
    return _partidas.fold(
      0.0,
      (total, partida) => total + calcularSubtotalPartida(partida, tipoCliente),
    );
  }
}
