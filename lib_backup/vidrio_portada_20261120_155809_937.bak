import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VidrioPortada extends StatelessWidget {
  final Widget child;
  final double radio;
  final bool oscuro;

  const VidrioPortada({super.key, required this.child, this.radio = 26, this.oscuro = false});

  @override
  Widget build(BuildContext context) {
    final contraste = AppTheme.modo == 'contrast';
    final base = oscuro ? AppTheme.btn : AppTheme.surface;
    final borde = BorderRadius.circular(radio);
    final cristal = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borde,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: contraste ? [base, base] : [
            base.withValues(alpha: oscuro ? 0.95 : 0.89),
            base.withValues(alpha: oscuro ? 0.85 : 0.55),
            base.withValues(alpha: oscuro ? 0.9 : 0.70),
          ],
        ),
        border: Border.all(color: contraste ? AppTheme.line : Colors.white.withValues(alpha: oscuro ? 0.32 : 0.85)),
      ),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borde,
        boxShadow: [
          if (!contraste) const BoxShadow(color: Color(0x240F1118), blurRadius: 25, offset: Offset(0, 11)),
        ],
      ),
      child: ClipRRect(
        borderRadius: borde,
        child: contraste ? cristal : BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), child: cristal),
      ),
    );
  }
}
