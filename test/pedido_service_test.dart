import 'package:flutter_test/flutter_test.dart';
import 'package:vivero_temixco/models/partida.dart';
import 'package:vivero_temixco/models/pedido.dart';
import 'package:vivero_temixco/models/planta.dart';
import 'package:vivero_temixco/models/tipo_cliente.dart';
import 'package:vivero_temixco/services/pedido_service.dart';
import 'package:vivero_temixco/services/promocion_service.dart';

void main() {
  final planta = Planta(
    id: 'p1',
    nombre: 'Rosa',
    precioBase: 100.0,
    existencia: 50,
  );

  tearDown(() => PromocionService.temporadaActiva = false);

  test('confirmar fija el total cobrado con la promoción vigente', () {
    final servicio = PedidoService();
    final pedido = servicio.crearPedido([
      Partida(planta: planta, cantidad: 2),
    ], TipoCliente.general);

    PromocionService.temporadaActiva = true;
    servicio.confirmar(pedido);

    expect(pedido.estado, EstadoPedido.confirmado);
    expect(pedido.totalCobrado, closeTo(170.0, 0.001));
  });

  test('el corte no cambia si la promoción se apaga después de confirmar', () {
    final servicio = PedidoService();
    final pedido = servicio.crearPedido([
      Partida(planta: planta, cantidad: 2),
    ], TipoCliente.general);

    PromocionService.temporadaActiva = true;
    servicio.confirmar(pedido);
    PromocionService.temporadaActiva = false;

    expect(servicio.corteDelDia(), closeTo(170.0, 0.001));
  });

  test('el corte ignora pendientes y rechazados', () {
    final servicio = PedidoService();
    final confirmado = servicio.crearPedido([
      Partida(planta: planta, cantidad: 1),
    ], TipoCliente.general);
    final rechazado = servicio.crearPedido([
      Partida(planta: planta, cantidad: 5),
    ], TipoCliente.general);
    servicio.crearPedido([
      Partida(planta: planta, cantidad: 9),
    ], TipoCliente.general);

    servicio.confirmar(confirmado);
    servicio.rechazar(rechazado);

    expect(servicio.corteDelDia(), 100.0);
  });
}
