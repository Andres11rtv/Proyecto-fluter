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
    TemaMuseoActivo.observar(context);
    return Stack(fit: StackFit.passthrough, children: [
      Positioned.fill(child: AppTheme.modo == 'light'
          ? _vidrioOriginal(context, const SizedBox.expand())
          : DecoratedBox(decoration: BoxDecoration(
              color: oscuro ? AppTheme.btn : AppTheme.surface,
              borderRadius: BorderRadius.circular(radio),
              border: Border.all(color: AppTheme.line)))),
      ClipRRect(borderRadius: BorderRadius.circular(radio), child: child),
    ]);
  }

  Widget _vidrioOriginal(BuildContext context, Widget child) {
    final contraste = AppTheme.modo == 'contrast';
    final base = oscuro ? AppTheme.btn : AppTheme.surface;
    final borde = BorderRadius.circular(radio);
    final cristal = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borde,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: contraste
              ? [base, base]
              : oscuro || AppTheme.modo == 'dark'
                  ? const [
                      Color(0xD9232830),
                      Color(0xBB171B22),
                      Color(0xCC262527),
                    ]
                  : const [
                      Color(0x70FFF7E8),
                      Color(0x36EAD6B9),
                      Color(0x4DD4BFA3),
                    ],
        ),
        border: Border.all(
          color: contraste
              ? AppTheme.line
              : oscuro || AppTheme.modo == 'dark'
                  ? const Color(0x45EFE2CF)
                  : const Color(0x91FFF3DF),
          width: 1,
        ),),
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
