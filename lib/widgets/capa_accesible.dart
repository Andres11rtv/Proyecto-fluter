import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../theme/app_theme.dart';
import 'accesibilidad_widget.dart';

class CapaAccesible extends StatefulWidget {
  const CapaAccesible({super.key, required this.child});
  final Widget child;

  @override
  State<CapaAccesible> createState() => _CapaAccesibleState();
}

class _EscalaMuseo extends TextScaler {
  const _EscalaMuseo(this.sistema, this.factor);
  final TextScaler sistema;
  final double factor;
  @override
  double scale(double fontSize) => sistema.scale(fontSize) * factor;
  @override
  double get textScaleFactor => scale(14) / 14;
}

class _CapaAccesibleState extends State<CapaAccesible> {
  final abrir = FocusNode(debugLabel: 'Abrir accesibilidad');
  final cerrar = FocusNode(debugLabel: 'Cerrar accesibilidad');
  final panel = FocusScopeNode(traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop);
  late final SemanticsHandle semantica;
  bool abierto = false;
  bool pausa = false;

  @override
  void initState() {
    super.initState();
    semantica = SemanticsBinding.instance.ensureSemantics();
  }

  @override
  void dispose() {
    abrir.dispose();
    cerrar.dispose();
    panel.dispose();
    semantica.dispose();
    super.dispose();
  }

  void mostrar(bool valor) {
    setState(() => abierto = valor);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) (valor ? cerrar : abrir).requestFocus();
    });
  }

  Widget opciones(double escala, bool amplia, bool sistemaReducido) {
    final modo = AccesibilidadMuseo.modoTema.value;
    return Material(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppTheme.bronze),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Semantics(header: true, child: Text('Accesibilidad',
                style: Theme.of(context).textTheme.titleLarge))),
            IconButton(focusNode: cerrar, tooltip: 'Cerrar accesibilidad',
                onPressed: () => mostrar(false), icon: const Icon(Icons.close)),
          ]),
          const Divider(),
          Text('Tamaño del texto · ${(escala * 100).round()} %'),
          Wrap(spacing: 8, runSpacing: 4, children: [
            IconButton(tooltip: 'Reducir tamaño del texto',
                onPressed: escala <= 0.851 ? null : () =>
                    AccesibilidadMuseo.cambiarEscala(escala - 0.15),
                icon: const Icon(Icons.text_decrease)),
            IconButton(tooltip: 'Aumentar tamaño del texto',
                onPressed: escala >= 1.999 ? null : () =>
                    AccesibilidadMuseo.cambiarEscala(escala + 0.15),
                icon: const Icon(Icons.text_increase)),
          ]),
          const SizedBox(height: 12),
          Semantics(header: true, child: const Text('Apariencia del museo')),
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final opcion in const {'light':'Claro','dark':'Oscuro','contrast':'Alto contraste'}.entries)
              ChoiceChip(materialTapTargetSize: MaterialTapTargetSize.padded, label: Text(opcion.value), selected: modo == opcion.key,
                  showCheckmark: true, onSelected: (_) => AccesibilidadMuseo.cambiarModo(opcion.key)),
          ]),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Lectura espaciada'),
            value: amplia, onChanged: (v) => AccesibilidadMuseo.lecturaAmplia.value = v),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Reducir movimiento'),
            subtitle: sistemaReducido ? const Text('Activado en tu dispositivo') : null,
            value: pausa || sistemaReducido,
            onChanged: sistemaReducido ? null : (v) => setState(() => pausa = v)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Usa Tab para avanzar, Mayús + Tab para volver y Escape para cerrar. Alt + A abre el panel.')),
          OutlinedButton(onPressed: () {
            AccesibilidadMuseo.restablecer();
            setState(() => pausa = false);
          }, child: const Text('Restablecer preferencias')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([AccesibilidadMuseo.escalaTexto,
        AccesibilidadMuseo.modoTema, AccesibilidadMuseo.lecturaAmplia]),
      builder: (context, _) {
        final escala = AccesibilidadMuseo.escalaTexto.value;
        final amplia = AccesibilidadMuseo.lecturaAmplia.value;
        final reducir = pausa || base.disableAnimations;
        final tema = Theme.of(context);
        return MediaQuery(
          data: base.copyWith(textScaler: _EscalaMuseo(base.textScaler, escala),
              disableAnimations: reducir),
          child: Theme(data: tema.copyWith(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            textTheme: amplia ? tema.textTheme.apply(
              bodyColor: AppTheme.ink, displayColor: AppTheme.ink,
            ).copyWith(bodyMedium: tema.textTheme.bodyMedium?.copyWith(
              height: 1.65, letterSpacing: 0.6)) : tema.textTheme,
          ), child: CallbackShortcuts(bindings: {
            const SingleActivator(LogicalKeyboardKey.keyA, alt: true): () => mostrar(!abierto),
            if (abierto) const SingleActivator(LogicalKeyboardKey.escape): () => mostrar(false),
          }, child: Overlay.wrap(child: Stack(fit: StackFit.expand, children: [
            ExcludeFocus(excluding: abierto, child: ExcludeSemantics(excluding: abierto,
              child: TemaMuseoActivo(modo: AccesibilidadMuseo.modoTema.value, child: widget.child))),
            if (!abierto) PositionedDirectional(end: 16, bottom: 16, child: SafeArea(
              child: AnimatedBuilder(animation: abrir, builder: (context, _) => DecoratedBox(decoration: ShapeDecoration(shape: CircleBorder(side: BorderSide(color: abrir.hasFocus ? AppTheme.ink : Colors.transparent, width: 3))), child: Padding(padding: const EdgeInsets.all(4), child: FloatingActionButton(focusNode: abrir, heroTag: null,
                shape: CircleBorder(side: BorderSide(color: AppTheme.bronze, width: 2)),
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.ink,
                focusColor: AppTheme.bronzeLight,
                tooltip: 'Abrir accesibilidad', onPressed: () => mostrar(true),
                child: const Icon(Icons.accessibility_new_rounded))))))),
            if (abierto) ...[
              ModalBarrier(color: Colors.black54, dismissible: true,
                semanticsLabel: 'Cerrar accesibilidad', onDismiss: () => mostrar(false)),
              SafeArea(child: Padding(padding: const EdgeInsets.all(12),
                child: Align(alignment: AlignmentDirectional.bottomEnd,
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 370),
                    child: FocusScope(node: panel,
                      child: Semantics(scopesRoute: true, namesRoute: true, label: 'Accesibilidad',
                        explicitChildNodes: true, child: opciones(escala, amplia, base.disableAnimations))))))),
            ],
          ])))),
        );
      },
    );
  }
}