import 'vidrio_portada.dart';
import 'imagen_obra.dart';
import 'package:flutter/material.dart';
import '../models/obra.dart';

import '../services/museo_service_impl.dart';
import '../services/recorrido_service_impl.dart';
import '../screens/coleccion_screen.dart';
import '../screens/el_museo_screen.dart';
import '../screens/obra_detalle_screen.dart';
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

  void abrir(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  Widget indicador(IconData icon, String nombre, int? cantidad, Widget destino) {
    return InkWell(onTap: () => abrir(destino), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppTheme.bronze, size: 22),
        const SizedBox(height: 6),
        Text(cantidad?.toString() ?? '—', style: AppTheme.serif(size: 28)),
        Text(nombre, style: AppTheme.sans(size: 12)),
      ]),
    ));
  }

  Widget flecha(String etiqueta, IconData icono, VoidCallback accion) {
    return IconButton.outlined(
      tooltip: etiqueta, onPressed: accion, icon: Icon(icono, size: 16),
      style: IconButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }

  Widget seleccion(AsyncSnapshot<List<Obra>> datos) {
    if (datos.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final piezas = datos.data ?? [];
    if (piezas.isEmpty) {
      return ListTile(title: Text(datos.hasError ? 'Colección no disponible' : 'Sin obras registradas'),
        trailing: const Icon(Icons.chevron_right), onTap: () => abrir(const ColeccionScreen()));
    }
    final obra = piezas[indice];
    final foto = ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(
      width: 98, height: 112, child: ImagenObra(url: obra.imagenUrl, nombre: obra.nombre, miniatura: true)));
    final ficha = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('OBRA DESTACADA', style: AppTheme.sans(size: 10, weight: FontWeight.w700, color: AppTheme.bronze, letterSpacing: 1.1)),
        if (piezas.length > 1) Row(mainAxisSize: MainAxisSize.min, children: [
          flecha('Anterior', Icons.chevron_left, () => setState(() => indice = (indice - 1) % piezas.length)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('${indice + 1} / ${piezas.length}', style: AppTheme.sans(size: 12))),
          flecha('Siguiente', Icons.chevron_right, () => setState(() => indice = (indice + 1) % piezas.length)),
        ]),
      ]),
      const SizedBox(height: 6),
      Text(obra.nombre, style: AppTheme.serif(size: 20, weight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
      Text(obra.descripcion, style: AppTheme.sans(size: 13.5, height: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
      TextButton(onPressed: () => abrir(ObraDetalleScreen(obra: obra)), child: const Text('Ver ficha curatorial →')),
    ]);
    return MediaQuery.sizeOf(context).width < 440 || MediaQuery.textScalerOf(context).scale(16) > 21
      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [foto, ficha])
      : Row(children: [foto, const SizedBox(width: 12), Expanded(child: ficha)]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Obra>>(future: widget.obras, builder: (context, datos) {
      final tarjetas = <Widget>[
        VidrioPortada(child: Padding(padding: const EdgeInsets.all(16), child: Center(child: seleccion(datos)))),
        VidrioPortada(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: indicador(Icons.image_outlined, 'Obras catalogadas', datos.data?.length, const ColeccionScreen())),
          SizedBox(height: 86, child: VerticalDivider(width: 1, color: AppTheme.line)),
          Expanded(child: FutureBuilder<int>(future: museos, builder: (_, s) => indicador(Icons.account_balance_outlined, 'Sedes de museo', s.data, const ElMuseoScreen()))),
          SizedBox(height: 86, child: VerticalDivider(width: 1, color: AppTheme.line)),
          Expanded(child: FutureBuilder<int>(future: rutas, builder: (_, s) => indicador(Icons.route_outlined, 'Recorridos', s.data, const RecorridosScreen()))),
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
              Text('Visitas guiadas', style: AppTheme.serif(size: 23, color: AppTheme.btnTexto)),
              Text('Ver recorridos y horarios →', style: AppTheme.sans(color: AppTheme.btnTexto)),
            ]),
          ),
        ))),
      ];
      return LayoutBuilder(builder: (context, box) {
        if (box.maxWidth < 850 || MediaQuery.textScalerOf(context).scale(16) > 21) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final tarjeta in tarjetas) Padding(padding: const EdgeInsets.only(bottom: 12), child: tarjeta),
          ]);
        }
        return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: 14, child: tarjetas[0]), const SizedBox(width: 16),
          Expanded(flex: 13, child: tarjetas[1]), const SizedBox(width: 16),
          Expanded(flex: 8, child: tarjetas[2]),
        ]));
      });
    });
  }
}
