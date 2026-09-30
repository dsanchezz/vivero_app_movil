import '../models/pedido.dart';
import '../models/tipo_cliente.dart';

String formatoPrecio(double monto) => '\$${monto.toStringAsFixed(2)}';

String nombreTipoCliente(TipoCliente tipo) => switch (tipo) {
  TipoCliente.general => 'General',
  TipoCliente.mayorista => 'Mayorista',
};

String nombreEstado(EstadoPedido estado) => switch (estado) {
  EstadoPedido.pendiente => 'Pendiente',
  EstadoPedido.confirmado => 'Confirmado',
  EstadoPedido.rechazado => 'Rechazado',
};
