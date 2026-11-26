import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_museo/theme/app_theme.dart';
import 'package:proyecto_museo/widgets/accesibilidad_widget.dart';
import 'package:proyecto_museo/widgets/capa_accesible.dart';

double contraste(Color texto, Color fondo) {
  final a = texto.computeLuminance();
  final b = fondo.computeLuminance();
  return a >= b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
}

void main() {
  test('Contraste del texto en superficies solidas de las tres paletas', () {
    addTearDown(AccesibilidadMuseo.restablecer);
    for (final modo in ['light', 'dark', 'contrast']) {
      AccesibilidadMuseo.cambiarModo(modo);
      for (final color in [AppTheme.ink, AppTheme.muted, AppTheme.bronze]) {
        expect(contraste(color, AppTheme.surface), greaterThanOrEqualTo(7),
            reason: 'Modo $modo, texto $color sobre la superficie del museo');
      }
      expect(contraste(AppTheme.btnTexto, AppTheme.btn), greaterThanOrEqualTo(7));
    }
  });

  testWidgets('El panel cambia un fondo ya visible y conserva el formulario', (tester) async {
    final campo = TextEditingController();
    addTearDown(campo.dispose);
    addTearDown(AccesibilidadMuseo.restablecer);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => CapaAccesible(child: child!),
      home: Scaffold(body: MuseoBackdrop(child: Center(child: TextField(controller: campo)))),
    ));
    await tester.enterText(find.byType(TextField), 'Van Gogh');
    final estado = tester.state(find.byType(TextField));
    for (final opcion in ['Oscuro', 'Alto contraste', 'Claro']) {
      final boton = find.byTooltip('Abrir accesibilidad');
      expect(tester.widget<FloatingActionButton>(find.byType(FloatingActionButton)).shape, isA<CircleBorder>());
      expect(tester.getSize(find.byType(FloatingActionButton)).shortestSide, greaterThanOrEqualTo(44));
      await tester.tap(boton);
      await tester.pumpAndSettle();
      final chip = find.widgetWithText(ChoiceChip, opcion);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      final cerrar = find.byTooltip('Cerrar accesibilidad');
      await tester.ensureVisible(cerrar);
      await tester.tap(cerrar);
      await tester.pumpAndSettle();
      final fondo = find.byKey(const ValueKey('fondo-museo-activo'));
      if (opcion == 'Claro') {
        expect(fondo, findsNothing);
      } else {
        expect(tester.widget<ColoredBox>(fondo).color, AppTheme.bg);
      }
      expect(tester.state(find.byType(TextField)), same(estado));
      expect(campo.text, 'Van Gogh');
    }
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}