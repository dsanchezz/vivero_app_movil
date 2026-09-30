/// Algoritmo de precio unitario para un [TipoCliente] (Strategy).
///
/// Cada regla de negocio (general, mayorista, la que siga mañana) vive en su
/// propia clase en vez de en un condicional compartido, así que agregar una
/// regla nueva no obliga a tocar ni releer las demás.
abstract class EstrategiaPrecio {
  double precioUnitario({
    required double precioBase,
    required int cantidad,
    required bool promocionActiva,
  });
}
