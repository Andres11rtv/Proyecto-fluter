import 'package:flutter/material.dart';

class AlPasar extends StatefulWidget {
  final Widget child;
  final bool ampliar;
  const AlPasar({super.key, required this.child, this.ampliar = false});

  @override
  State<AlPasar> createState() => _AlPasarState();
}

class _AlPasarState extends State<AlPasar> {
  bool encima = false;

  @override
  Widget build(BuildContext context) {
    final activo = encima && !MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => encima = true),
      onExit: (_) => setState(() => encima = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.ampliar ? 420 : 180),
        curve: Curves.easeOutCubic, transformAlignment: Alignment.center,
        transform: widget.ampliar
            ? Matrix4.diagonal3Values(activo ? 1.05 : 1, activo ? 1.05 : 1, 1)
            : Matrix4.translationValues(0, activo ? -3 : 0, 0),
        child: widget.child,
      ),
    );
  }
}

class EntradaTexto extends StatefulWidget {
  final Widget child;
  const EntradaTexto({super.key, required this.child});

  @override
  State<EntradaTexto> createState() => _EntradaTextoState();
}

class _EntradaTextoState extends State<EntradaTexto> {
  ScrollPosition? posicion;
  bool visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    posicion?.removeListener(comprobar);
    posicion = Scrollable.maybeOf(context)?.position;
    if (!visible) {
      posicion?.addListener(comprobar);
      WidgetsBinding.instance.addPostFrameCallback((_) => comprobar());
    }
  }

  void comprobar() {
    if (!mounted || visible) return;
    final caja = context.findRenderObject();
    if (caja is! RenderBox || !caja.hasSize) return;
    final y = caja.localToGlobal(Offset.zero).dy;
    if (y < MediaQuery.sizeOf(context).height && y + caja.size.height > 0) {
      posicion?.removeListener(comprobar);
      setState(() => visible = true);
    }
  }

  @override
  void dispose() {
    posicion?.removeListener(comprobar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedSlide(offset: visible ? Offset.zero : const Offset(0, 0.10),
      duration: const Duration(milliseconds: 320), curve: Curves.easeOut,
      child: AnimatedOpacity(opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 320), child: widget.child));
  }
}
