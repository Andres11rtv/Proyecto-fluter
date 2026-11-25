import 'imagen_obra.dart';
import 'package:flutter/material.dart';
import '../models/obra.dart';
import '../services/artista_service_impl.dart';
import '../services/categoria_service_impl.dart';
import '../screens/coleccion_screen.dart';
import '../screens/obra_detalle_screen.dart';
import '../screens/obras_screen.dart';
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
    return Card(clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: () => widget.abrir(ObraDetalleScreen(obra: obra)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(aspectRatio: 1.55, child: Stack(fit: StackFit.expand, children: [
          ImagenObra(url: obra.imagenUrl, nombre: obra.nombre),
          if (categoria != null) Positioned(left: 12, top: 12,
            child: Chip(label: Text(categoria))),
        ])),
        Padding(padding: const EdgeInsets.all(20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(obra.nombre, style: AppTheme.serif(size: 26)),
            Text(artistas[obra.idArtista] ?? 'Sin artista atribuido'),
            const SizedBox(height: 14),
            Wrap(spacing: 18, children: [
              Text('${obra.fechaCreacion.year}'),
              Text('Explorar obra →', style: AppTheme.sans(color: AppTheme.bronze)),
            ]),
          ],
        )),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('CURADURÍA DESTACADA', style: AppTheme.sans(size: 11, letterSpacing: 2.5, color: AppTheme.bronze)),
      Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16, runSpacing: 8, children: [
          Text('Explora la colección', style: AppTheme.serif(size: 38)),
          OutlinedButton(onPressed: () => widget.abrir(const ObrasScreen()), child: const Text('Gestionar catálogo')),
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
        }).toList() : snap.requireData.take(3).toList();
        if (piezas.isEmpty && termino.isNotEmpty) return Text('Sin resultados para «${widget.busqueda}».');
        if (piezas.isEmpty) return const Text('Aún no hay obras registradas.');
        return LayoutBuilder(builder: (context, box) {
          final columnas = box.maxWidth >= 860 ? 3 : box.maxWidth >= 580 ? 2 : 1;
          return Wrap(spacing: 16, runSpacing: 16, children: [
            for (final obra in piezas) SizedBox(
              width: (box.maxWidth - 16 * (columnas - 1)) / columnas, child: tarjeta(obra)),
          ]);
        });
      }),
      if (!widget.completa) Align(alignment: Alignment.centerRight, child: TextButton(
        onPressed: () => widget.abrir(const ColeccionScreen()), child: const Text('Ver toda la colección →'))),
    ]);
  }
}
