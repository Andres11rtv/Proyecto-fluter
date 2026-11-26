import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_museo/widgets/capa_accesible.dart';

void main() {
  testWidgets('Panel móvil, escala del sistema, pausa y cierre con Escape',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var escala = 0.0;
    var pausa = false;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(1.25), disableAnimations: false),
        child: CapaAccesible(child: child!)),
      home: Scaffold(body: Builder(builder: (context) {
        escala = MediaQuery.textScalerOf(context).scale(16);
        pausa = MediaQuery.disableAnimationsOf(context);
        return const Text('Colección');
      })),
    ));
    expect(escala, 20);
    await tester.tap(find.byTooltip('Abrir accesibilidad'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Aumentar tamaño del texto'));
    await tester.tap(find.byTooltip('Aumentar tamaño del texto'));
    await tester.pumpAndSettle();
    expect(escala, greaterThan(20));
    for (var i = 0; i < 6; i++) {
      await tester.ensureVisible(find.byTooltip('Aumentar tamaño del texto'));
      await tester.tap(find.byTooltip('Aumentar tamaño del texto'));
      await tester.pumpAndSettle();
    }
    expect(escala, closeTo(40, 0.01));
    await tester.ensureVisible(find.text('Reducir movimiento'));
    await tester.tap(find.text('Reducir movimiento'));
    await tester.pumpAndSettle();
    expect(pausa, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Abrir accesibilidad'), findsOneWidget);
    expect(find.text('Apariencia del museo'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}