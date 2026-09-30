import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vivero_temixco/main.dart';
import 'package:vivero_temixco/services/promocion_service.dart';

// Recorre el flujo completo: armar pedido, enviarlo, confirmarlo y ver que el
// corte no cambia al apagar la promoción después de confirmar.
void main() {
  tearDown(() => PromocionService.temporadaActiva = false);

  testWidgets('armar, enviar y confirmar un pedido', (tester) async {
    await tester.pumpWidget(const MainApp());

    // Encargada activa la promoción.
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Cliente general agrega 2 rosas ($120 × 0.85 × 2 = $204).
    await tester.tap(find.text('Catálogo'));
    await tester.pumpAndSettle();
    final agregarRosa = find.descendant(
      of: find.widgetWithText(ListTile, 'Rosa'),
      matching: find.byIcon(Icons.add_circle_outline),
    );
    await tester.tap(agregarRosa);
    await tester.pump();
    await tester.tap(agregarRosa);
    await tester.pump();
    expect(find.text('Total: \$204.00'), findsOneWidget);

    await tester.tap(find.text('Enviar pedido'));
    await tester.pump();
    expect(find.text('Total: \$0.00'), findsOneWidget);

    // Encargada confirma y luego apaga la promoción.
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(find.text('Cobrado: \$204.00'), findsOneWidget);
    expect(find.text('\$204.00'), findsOneWidget); // corte del día
  });
}
