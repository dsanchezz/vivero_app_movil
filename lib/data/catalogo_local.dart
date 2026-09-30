import '../models/planta.dart';

/// Datos de catálogo para probar la app mientras no hay servidor disponible.
/// Cuando exista la API propia del vivero, esta clase se reemplaza por un
/// cliente HTTP con la misma forma de retorno.
class CatalogoLocal {
  static const List<Planta> plantas = [
    Planta(id: 'p1', nombre: 'Rosa', precioBase: 120.0, existencia: 15),
    Planta(id: 'p2', nombre: 'Cactus', precioBase: 45.0, existencia: 30),
    Planta(id: 'p3', nombre: 'Helecho', precioBase: 90.0, existencia: 8),
    Planta(id: 'p4', nombre: 'Buganvilia', precioBase: 150.0, existencia: 12),
  ];
}
