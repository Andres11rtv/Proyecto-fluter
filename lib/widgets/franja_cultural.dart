import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'vidrio_portada.dart';

class FranjaCultural extends StatefulWidget {
  const FranjaCultural({super.key});
  @override
  State<FranjaCultural> createState() => _FranjaCulturalState();
}

class _FranjaCulturalState extends State<FranjaCultural> with SingleTickerProviderStateMixin {
  late final movimiento = AnimationController(vsync: this, duration: const Duration(seconds: 32));
  bool pausada = false;
  static const temas = ['GALERÍA DE ANTIGÜEDADES', 'PINTURA BARROCA EUROPEA',
    'VANGUARDIA LATINOAMERICANA', 'PATRIMONIO & RESTAURACIÓN', 'VISITAS CURATORIALES'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ajustarMovimiento();
  }

  void ajustarMovimiento() {
    if (pausada || MediaQuery.disableAnimationsOf(context)) {
      movimiento.stop();
    } else if (!movimiento.isAnimating) {
      movimiento.repeat();
    }
  }

  @override
  void dispose() {
    movimiento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    final fila = Row(mainAxisSize: MainAxisSize.min, children: [
      for (final tema in temas) Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Text(tema, style: AppTheme.sans(size: 13, letterSpacing: 1.5, weight: FontWeight.w700)),
          const SizedBox(width: 16), Text('✦', style: TextStyle(color: AppTheme.bronze)),
        ]),
      ),
    ]);
    return MouseRegion(
      onEnter: (_) { pausada = true; ajustarMovimiento(); },
      onExit: (_) { pausada = false; ajustarMovimiento(); },
      child: Semantics(label: temas.join(', '), child: ExcludeSemantics(child: VidrioPortada(radio: 99,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, physics: const NeverScrollableScrollPhysics(),
        child: SlideTransition(position: Tween(begin: Offset.zero, end: const Offset(-0.5, 0)).animate(movimiento),
          child: Row(children: [fila, fila])),
      )),
    ))));
  }
}
