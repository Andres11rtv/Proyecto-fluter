import '../rutas_museo.dart';
import 'dart:async';
import 'seleccion_destacada.dart';
import 'tarjeta_interactiva.dart';
import 'vidrio_portada.dart';
import 'imagen_obra.dart';
import 'package:flutter/material.dart';
import '../models/obra.dart';

import '../services/museo_service_impl.dart';
import '../services/recorrido_service_impl.dart';
import '../screens/coleccion_screen.dart';
// Los totales de portada son informativos.
import 'vista_curatorial.dart';
import '../screens/recorridos_screen.dart';
import '../theme/app_theme.dart';

class PortadaColeccion extends StatefulWidget {
  final Future<List<Obra>> obras;
  const PortadaColeccion({super.key, required this.obras});

  @override
  State<PortadaColeccion> createState() => _PortadaColeccionState();
}

class _PortadaColeccionState extends State<PortadaColeccion> {

  late final museos = MuseoServiceImpl().obtenerMuseos().then((m) => m.length);
  late final rutas = RecorridoServiceImpl().obtenerRecorridos().then((r) => r.length);
  int indice = 0;
  Timer? cambioAutomatico;
  bool cursorEnTarjeta = false;
  bool focoEnTarjeta = false;
  int cantidad = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sincronizarReloj();
  }

  void sincronizarReloj() {
    cambioAutomatico?.cancel();
    if (cursorEnTarjeta || focoEnTarjeta || MediaQuery.disableAnimationsOf(context)) return;
    cambioAutomatico = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && cantidad > 1 && ModalRoute.of(context)?.isCurrent == true) {
        setState(() => indice = (indice + 1) % cantidad);
      }
    });
  }

  @override
  void dispose() {
    cambioAutomatico?.cancel();
    super.dispose();
  }

  bool sobreFoto = false;

  void abrir(Widget pantalla) {
    Navigator.push(context, rutaMuseo(pantalla));
  }

  Widget indicador(IconData icon, String nombre, int? cantidad) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppTheme.bronze, size: 22),
        const SizedBox(height: 6),
        Text(cantidad?.toString() ?? '—', style: AppTheme.serif(size: 28)),
        Text(nombre, style: AppTheme.sans(size: 12)),
      ]),
    );
  }

  Widget flecha(String etiqueta, IconData icono, VoidCallback accion) {
    return IconButton.outlined(
      tooltip: etiqueta, onPressed: accion, icon: Icon(icono, size: 16),
      style: IconButton.styleFrom(minimumSize: const Size(48, 48), padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }

  Widget transicionObra(int id, Widget contenido) {
    final duracion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero : const Duration(milliseconds: 380);
    return AnimatedSize(duration: duracion, alignment: Alignment.centerLeft,
      curve: Curves.easeInOutCubic, child: AnimatedSwitcher(
        duration: duracion,
        transitionBuilder: (child, animacion) => FadeTransition(
          opacity: animacion.drive(CurveTween(curve: const Interval(0.22, 1, curve: Curves.easeInOut))),
          child: child),
        layoutBuilder: (actual, anteriores) => Stack(alignment: Alignment.centerLeft, children: [
          for (final anterior in anteriores) ExcludeSemantics(child: IgnorePointer(child: anterior)),
          ?actual,
        ]),
        child: KeyedSubtree(key: ValueKey(id), child: contenido),
      ));
  }

  Widget seleccion(AsyncSnapshot<List<Obra>> datos) {
    if (datos.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final piezas = obrasDestacadas(datos.data ?? []);
    cantidad = piezas.length;
    if (piezas.isEmpty) {
      return ListTile(title: Text(datos.hasError ? 'Colección no disponible' : 'Aún no hay obras destacadas'),
        trailing: const Icon(Icons.chevron_right), onTap: () => abrir(const ColeccionScreen()));
    }
    final actual = indice % piezas.length;
    final obra = piezas[actual];
    final foto = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => sobreFoto = true),
      onExit: (_) => setState(() => sobreFoto = false),
      child: GestureDetector(onTap: () => mostrarFichaCuratorial(context, obra),
        child: ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(
          width: 112, height: 112, child: AnimatedScale(
            scale: sobreFoto && !MediaQuery.disableAnimationsOf(context) ? 1.05 : 1,
            duration: const Duration(milliseconds: 180),
            child: transicionObra(obra.id, SizedBox.expand(child: ImagenObra(url: obra.imagenUrl, nombre: obra.nombre, miniatura: true))))))),
    );
    final ficha = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('OBRAS DESTACADAS', style: AppTheme.sans(size: 10, weight: FontWeight.w700, color: AppTheme.bronze, letterSpacing: 1.1)),
        if (piezas.length > 1) Row(mainAxisSize: MainAxisSize.min, children: [
          flecha('Anterior', Icons.chevron_left, () => setState(() => indice = (indice - 1) % piezas.length)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('${(actual + 1).toString().padLeft(2, '0')} / ${piezas.length.toString().padLeft(2, '0')}', style: AppTheme.sans(size: 12))),
          flecha('Siguiente', Icons.chevron_right, () => setState(() => indice = (indice + 1) % piezas.length)),
        ]),
      ]),
      const SizedBox(height: 6),
      transicionObra(obra.id, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(obra.nombre, style: AppTheme.serif(size: 20, weight: FontWeight.w700),
          maxLines: 2, overflow: TextOverflow.ellipsis),
        Text(obra.descripcion, style: AppTheme.sans(size: 13.5, height: 1.45),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      ])),
      TextButton(style: TextButton.styleFrom(foregroundColor: AppTheme.bronze,
        textStyle: AppTheme.sans(size: 14, weight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(vertical: 4), alignment: Alignment.centerLeft),
        onPressed: () => mostrarFichaCuratorial(context, obra), child: const Text('Ver ficha curatorial')),
    ]);
    return MediaQuery.sizeOf(context).width < 440 || MediaQuery.textScalerOf(context).scale(16) > 21
      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [foto, ficha])
      : Row(children: [foto, const SizedBox(width: 12), Expanded(child: ficha)]);
  }

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    return FutureBuilder<List<Obra>>(future: widget.obras, builder: (context, datos) {
      final tarjetas = <Widget>[
        MouseRegion(onEnter: (_) { cursorEnTarjeta = true; sincronizarReloj(); },
          onExit: (_) { cursorEnTarjeta = false; sincronizarReloj(); },
          child: Focus(canRequestFocus: false, onFocusChange: (tieneFoco) {
            focoEnTarjeta = tieneFoco; sincronizarReloj();
          }, child: VidrioPortada(child: Padding(padding: const EdgeInsets.all(16), child: Center(child: seleccion(datos)))))),
        VidrioPortada(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: indicador(Icons.image_outlined, 'Obras catalogadas', datos.data?.length)),
          SizedBox(height: 134, child: VerticalDivider(width: 1, color: AppTheme.line)),
          Expanded(child: FutureBuilder<int>(future: museos, builder: (_, s) => indicador(Icons.account_balance_outlined, 'Sedes de museo', s.data))),
          SizedBox(height: 134, child: VerticalDivider(width: 1, color: AppTheme.line)),
          Expanded(child: FutureBuilder<int>(future: rutas, builder: (_, s) => indicador(Icons.route_outlined, 'Recorridos', s.data))),
        ]))),
        VidrioPortada(oscuro: true, child: Material(type: MaterialType.transparency, child: InkWell(
          onTap: () => abrir(const RecorridosScreen()), child: Padding(
            padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                ClipOval(child: Image.network('https://images.unsplash.com/photo-1554907984-15263bfd63bd?auto=format&fit=crop&w=120&q=80',
                  width: 38, height: 38, fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (_, _, _) => Icon(Icons.route_outlined, color: AppTheme.btnTexto))),
                DecoratedBox(decoration: BoxDecoration(color: AppTheme.btnTexto.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), child: Text('RECORRIDOS', style: AppTheme.sans(size: 10, weight: FontWeight.w700, color: AppTheme.btnTexto)))),
              ]),
              const SizedBox(height: 24),
              Text('Visitas guiadas', style: AppTheme.serif(size: 20, color: AppTheme.btnTexto)),
              Text('Explora nuestras rutas temáticas sala por sala.', style: AppTheme.sans(color: AppTheme.btnTexto)),
            ]),
          ),
        ))),
      ];
      return LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < 850 || MediaQuery.textScalerOf(context).scale(16) > 21) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < tarjetas.length; i++) Padding(padding: const EdgeInsets.only(bottom: 12), child: TarjetaInteractiva(child: tarjetas[i])),
          ]);
        }
        return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: 14, child: TarjetaInteractiva(child: tarjetas[0])), const SizedBox(width: 16),
          Expanded(flex: 13, child: TarjetaInteractiva(child: tarjetas[1])), const SizedBox(width: 16),
          Expanded(flex: 8, child: TarjetaInteractiva(child: tarjetas[2])),
        ]));
      });
    });
  }
}
