import '../rutas_museo.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/obra.dart';
import '../screens/obra_detalle_screen.dart';
import '../services/artista_service_impl.dart';
import '../services/categoria_service_impl.dart';
import '../services/sala_service_impl.dart';
import '../theme/app_theme.dart';
import 'imagen_obra.dart';
import 'voz_local.dart' if (dart.library.js_interop) 'voz_web.dart' as voz;

Future<void> mostrarFichaCuratorial(BuildContext context, Obra obra,
    {String? autor, String? categoria}) async {
  final verCompleta = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.67),
    builder: (_) => _Ficha(obra: obra, autor: autor, categoria: categoria),
  );
  if (verCompleta == true && context.mounted) {
    await Navigator.push<void>(context, rutaMuseo(ObraDetalleScreen(obra: obra)));
  }
}

class _Ficha extends StatefulWidget {
  final Obra obra;
  final String? autor;
  final String? categoria;
  const _Ficha({required this.obra, this.autor, this.categoria});

  @override
  State<_Ficha> createState() => _FichaState();
}

class _FichaState extends State<_Ficha> {
  late final datos = cargar();
  bool ampliar = false;
  Alignment centro = Alignment.center;

  Future<List<String>> cargar() async {
    final obra = widget.obra;
    final artista = obra.idArtista;
    final sala = obra.idSala;
    final nombreAutor = widget.autor ?? (artista == null ? null :
        (await ArtistaServiceImpl().obtenerArtistaPorId(artista))?.nombre);
    final categoria = widget.categoria ??
        (await CategoriaServiceImpl().obtenerCategoriaPorId(obra.idCategoria))?.nombre;
    final nombreSala = sala == null ? null : (await SalaServiceImpl().obtenerSalaPorId(sala))?.nombre;
    return [nombreAutor ?? 'Autor por atribuir', categoria ?? 'Obra', nombreSala ?? 'Sin sala asignada'];
  }

  @override
  void dispose() {
    if (voz.vozDisponible) voz.silenciar();
    super.dispose();
  }

  Widget fotografia(bool compacta) {
    return LayoutBuilder(builder: (context, caja) {
      return ClipRect(child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        onEnter: (_) => setState(() => ampliar = true),
        onExit: (_) => setState(() => ampliar = false),
        onHover: (evento) => setState(() => centro = Alignment(
          (2 * evento.localPosition.dx / caja.maxWidth - 1).clamp(-1.0, 1.0).toDouble(),
          (2 * evento.localPosition.dy / caja.maxHeight - 1).clamp(-1.0, 1.0).toDouble())),
        child: Stack(fit: StackFit.expand, children: [
          AnimatedScale(scale: ampliar ? 1.48 : 1, alignment: centro,
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 170),
            child: ImagenObra(url: widget.obra.imagenUrl, nombre: widget.obra.nombre)),
          if (!compacta) Positioned(left: 14, bottom: 14, child: IgnorePointer(child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Text('Pasa el cursor para inspeccionar el detalle', style: TextStyle(color: Colors.white, fontSize: 12)))))),
        ]),
      ));
    });
  }

  Widget ficha() {
    final obra = widget.obra;
    return FutureBuilder<List<String>>(future: datos, builder: (context, estado) {
      final nombres = estado.data;
      return Padding(padding: const EdgeInsets.fromLTRB(28, 38, 28, 28), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.only(right: 28), child: Text((nombres?[1] ?? 'Obra').toUpperCase(),
            style: AppTheme.sans(size: 11, letterSpacing: 2, weight: FontWeight.w700, color: AppTheme.bronze))),
          const SizedBox(height: 18),
          Text(obra.nombre, style: AppTheme.serif(size: 34, weight: FontWeight.w700, height: 1.06)),
          const SizedBox(height: 20),
          Text([if (nombres != null) nombres[0], obra.fechaCreacion.year.toString()].join(' · '),
            style: AppTheme.sans(size: 14, color: AppTheme.bronze, weight: FontWeight.w700)),
          if (estado.hasError) const Text('No se pudieron consultar los datos de sala y autor.'),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: [
            if (nombres != null) Chip(label: Text(nombres[2])),
            Chip(label: Text('Conservación ${obra.porcentajeConservacion}%')),
          ]),
          const SizedBox(height: 14),
          Text(obra.descripcion, style: AppTheme.sans(size: 15, height: 1.55)),
          if (voz.vozDisponible) ...[
            const SizedBox(height: 20),
            FilledButton.icon(icon: const Icon(Icons.volume_up_outlined, size: 18),
              label: const Text('Escuchar audioguía'),
              onPressed: () => voz.leer([obra.nombre, if (nombres != null) nombres[0],
                obra.fechaCreacion.year.toString(), obra.descripcion].join('. '))),
          ],
          SizedBox(height: voz.vozDisponible ? 12 : 20),
          OutlinedButton.icon(
  onPressed: () => Navigator.pop(context, true),
  icon: const Icon(Icons.menu_book_rounded, size: 18),
  label: const Text('Ver ficha completa'),
  style: OutlinedButton.styleFrom(
    foregroundColor: AppTheme.bronze,
    backgroundColor: AppTheme.bronze.withValues(alpha: 0.09),
    overlayColor: AppTheme.bronze,
    side: BorderSide(color: AppTheme.bronze.withValues(alpha: 0.55)),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    minimumSize: const Size(0, 44),
    textStyle: AppTheme.sans(size: 14, weight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
),
        ],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final compacta = MediaQuery.sizeOf(context).width < 700;
    return BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: Dialog(
      backgroundColor: AppTheme.surface, insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), clipBehavior: Clip.antiAlias,
      child: SizedBox(width: 820, height: compacta ? 600 : 430, child: Stack(children: [
        Positioned.fill(child: compacta
          ? ListView(children: [SizedBox(height: 210, child: fotografia(true)), ficha()])
          : Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(flex: 53, child: fotografia(false)),
              Expanded(flex: 47, child: SingleChildScrollView(child: ficha())),
            ])),
        Positioned(right: 10, top: 10, child: IconButton.filledTonal(
          tooltip: 'Cerrar ficha', icon: const Icon(Icons.close, size: 18),
          onPressed: () => Navigator.pop(context))),
      ])),
    ));
  }
}
