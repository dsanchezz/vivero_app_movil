import 'estrategia_precio.dart';

/// Cliente general: precio base, con descuento de temporada si aplica.
class PrecioGeneralStrategy implements EstrategiaPrecio {
  static const descuentoPromocion = 0.15;

  @override
  double precioUnitario({
    required double precioBase,
    required int cantidad,
    required bool promocionActiva,
  }) {
    return promocionActiva
        ? precioBase * (1 - descuentoPromocion)
        : precioBase;
  }
}
