import 'movimiento_portada.dart';
import 'tarjeta_interactiva.dart';
import 'seleccion_destacada.dart';
import 'imagen_obra.dart';
import 'package:flutter/material.dart';
import '../models/obra.dart';
import '../services/artista_service_impl.dart';
import '../services/categoria_service_impl.dart';
import '../screens/coleccion_screen.dart';
import 'vista_curatorial.dart';
import '../theme/app_theme.dart';

class GaleriaPortada extends StatefulWidget {
  final Future<List<Obra>> obras;
  final Future<void> Function(Widget) abrir;
  final bool completa;
  final String busqueda;
  const GaleriaPortada({super.key, required this.obras, required this.abrir,
    this.completa = false, this.busqueda = ''});
  @override
  State<GaleriaPortada> createState() => _GaleriaPortadaState();
}

class _GaleriaPortadaState extends State<GaleriaPortada> {
  late final datos = cargar();
  final artistas = <int, String>{};
  final categorias = <int, String>{};

  Future<List<Obra>> cargar() async {
    final piezas = await widget.obras;
    if (piezas.isEmpty) return piezas;
    for (final a in await ArtistaServiceImpl().obtenerArtistas()) {
      artistas[a.id] = a.nombre;
    }
    for (final c in await CategoriaServiceImpl().obtenerCategorias()) {
      categorias[c.id] = c.nombre;
    }
    return piezas;
  }

  Widget tarjeta(Obra obra) {
    final categoria = categorias[obra.idCategoria];
    return Card(margin: EdgeInsets.zero, elevation: 5, shadowColor: const Color(0x39726148),
      color: AppTheme.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppTheme.line)), clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: () => mostrarFichaCuratorial(context, obra, autor: artistas[obra.idArtista], categoria: categoria),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(aspectRatio: 1.48, child: Stack(fit: StackFit.expand, children: [
          ClipRect(child: AlPasar(ampliar: true, child: ImagenObra(url: obra.imagenUrl, nombre: obra.nombre))),
          if (categoria != null) Positioned(left: 12, top: 12,
            child: DecoratedBox(decoration: BoxDecoration(color: AppTheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.line)),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: Text(categoria, style: AppTheme.sans(size: 12, weight: FontWeight.w700))))),
        ])),
        Padding(padding: const EdgeInsets.all(24), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(obra.nombre, style: AppTheme.serif(size: 21, weight: FontWeight.w700)),
            Text(artistas[obra.idArtista] ?? 'Sin artista atribuido'),
            Divider(height: 32, color: AppTheme.line),
            SizedBox(width: double.infinity, child: Wrap(alignment: WrapAlignment.spaceBetween, spacing: 12, children: [
              Text('${obra.fechaCreacion.year}'),
              Text('Explorar obra', style: AppTheme.sans(color: AppTheme.bronze)),
            ])),
          ],
        )),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('CURADURÍA DESTACADA', style: AppTheme.sans(size: 11, letterSpacing: 2.5, color: AppTheme.bronze)),
      Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16, runSpacing: 8, children: [
          EntradaTexto(child: Text('Explora la colección', style: AppTheme.serif(size: 38))),
          if (!widget.completa)
            OutlinedButton.icon(
              onPressed: () => widget.abrir(const ColeccionScreen()),
              icon: const Icon(Icons.menu_book_rounded, size: 19),
              label: const Text('Ver catálogo completo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.bronze,
                backgroundColor: Color.alphaBlend(
                  AppTheme.bronze.withValues(alpha: 0.05), AppTheme.surface),
                side: BorderSide(color: AppTheme.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                textStyle: AppTheme.sans(size: 14, weight: FontWeight.w600),
              ),
            ),
        ]),
      const SizedBox(height: 16),
      FutureBuilder<List<Obra>>(future: datos, builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return const Text('No se pudo cargar la selección.');
        final termino = widget.busqueda.trim().toLowerCase();
        final piezas = widget.completa ? snap.requireData.where((obra) {
          final campos = [obra.nombre, obra.descripcion, artistas[obra.idArtista] ?? '',
            categorias[obra.idCategoria] ?? '', obra.fechaCreacion.year.toString()];
          return campos.any((campo) => campo.toLowerCase().contains(termino));
        }).toList() : {...obrasDestacadas(snap.requireData), ...snap.requireData}.take(3).toList();
        if (piezas.isEmpty && termino.isNotEmpty) return Text('Sin resultados para «${widget.busqueda}».');
        if (piezas.isEmpty) return const Text('Aún no hay obras registradas.');
        return LayoutBuilder(builder: (context, box) {
          final columnas = box.maxWidth >= 860 ? 3 : box.maxWidth >= 580 ? 2 : 1;
          return Wrap(spacing: 24, runSpacing: 24, children: [
            for (final obra in piezas) SizedBox(
              width: (box.maxWidth - 24 * (columnas - 1)) / columnas, child: TarjetaInteractiva(child: tarjeta(obra))),
          ]);
        });
      }),
    ]);
  }
}
