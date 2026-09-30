import 'estrategia_precio.dart';

/// Cliente mayorista: descuento por volumen, más descuento adicional de
/// temporada si la promoción está activa.
class PrecioMayoristaStrategy implements EstrategiaPrecio {
  static const umbralVolumen = 10;
  static const descuentoVolumenAlto = 0.20;
  static const descuentoVolumenBajo = 0.10;
  static const descuentoPromocionAdicional = 0.05;

  @override
  double precioUnitario({
    required double precioBase,
    required int cantidad,
    required bool promocionActiva,
  }) {
    final descuentoVolumen =
        cantidad >= umbralVolumen ? descuentoVolumenAlto : descuentoVolumenBajo;
    var precio = precioBase * (1 - descuentoVolumen);

    if (promocionActiva) {
      precio *= (1 - descuentoPromocionAdicional);
    }

    return precio;
  }
}
