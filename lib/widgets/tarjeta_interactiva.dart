import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TarjetaInteractiva extends StatefulWidget {
  final Widget child;
  const TarjetaInteractiva({super.key, required this.child});

  @override
  State<TarjetaInteractiva> createState() => _TarjetaInteractivaState();
}

class _TarjetaInteractivaState extends State<TarjetaInteractiva> {
  bool encima = false;

  @override
  Widget build(BuildContext context) {
    final reducir = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => encima = true),
      onExit: (_) => setState(() => encima = false),
      child: AnimatedContainer(
        duration: reducir ? Duration.zero : const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, encima && !reducir ? -4 : 0, 0),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: encima ? AppTheme.bronze : Colors.transparent),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: encima ? 0.13 : 0),
            blurRadius: 22, offset: const Offset(0, 8))],
        ),
        child: widget.child,
      ),
    );
  }
}
