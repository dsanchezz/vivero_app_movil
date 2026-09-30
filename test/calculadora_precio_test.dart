import 'package:flutter_test/flutter_test.dart';
import 'package:vivero_temixco/models/planta.dart';
import 'package:vivero_temixco/models/partida.dart';
import 'package:vivero_temixco/models/tipo_cliente.dart';
import 'package:vivero_temixco/services/pricing/calculadora_precio.dart';

// Los casos esperados reproducen, número por número, los condicionales
// anidados que existían antes del refactor (mismo comportamiento, otra forma).
void main() {
  final planta = Planta(
    id: 'p1',
    nombre: 'Rosa',
    precioBase: 100.0,
    existencia: 50,
  );
  final calculadora = CalculadoraPrecio();

  test('cliente general sin promoción: precio base', () {
    final partida = Partida(planta: planta, cantidad: 3);
    final total = calculadora.calcularPrecioPartida(
      partida,
      TipoCliente.general,
      promocionActiva: false,
    );
    expect(total, 300.0);
  });

  test('cliente general con promoción: 15% de descuento', () {
    final partida = Partida(planta: planta, cantidad: 3);
    final total = calculadora.calcularPrecioPartida(
      partida,
      TipoCliente.general,
      promocionActiva: true,
    );
    expect(total, closeTo(255.0, 0.001));
  });

  test('cliente mayorista, cantidad < 10, sin promoción: 10% de descuento', () {
    final partida = Partida(planta: planta, cantidad: 5);
    final total = calculadora.calcularPrecioPartida(
      partida,
      TipoCliente.mayorista,
      promocionActiva: false,
    );
    expect(total, closeTo(450.0, 0.001));
  });

  test('cliente mayorista, cantidad >= 10, sin promoción: 20% de descuento', () {
    final partida = Partida(planta: planta, cantidad: 12);
    final total = calculadora.calcularPrecioPartida(
      partida,
      TipoCliente.mayorista,
      promocionActiva: false,
    );
    expect(total, closeTo(960.0, 0.001));
  });

  test('cliente mayorista, cantidad >= 10, con promoción: 20% + 5% extra', () {
    final partida = Partida(planta: planta, cantidad: 12);
    final total = calculadora.calcularPrecioPartida(
      partida,
      TipoCliente.mayorista,
      promocionActiva: true,
    );
    expect(total, closeTo(912.0, 0.001));
  });
}
