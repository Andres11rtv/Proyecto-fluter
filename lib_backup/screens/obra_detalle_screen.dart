import 'package:flutter/material.dart';

import '../models/artista.dart';
import '../models/categoria.dart';
import '../models/obra.dart';
import '../models/sala.dart';
import '../services/contract/artista_service.dart';
import '../services/artista_service_impl.dart';
import '../services/contract/categoria_service.dart';
import '../services/categoria_service_impl.dart';
import '../services/contract/sala_service.dart';
import '../services/sala_service_impl.dart';
import '../theme/app_theme.dart';
import 'historial_screen.dart';

class ObraDetalleScreen extends StatelessWidget {
  final Obra obra;

  const ObraDetalleScreen({super.key, required this.obra});

  @override
  Widget build(BuildContext context) {
    final ArtistaService artistaServicio = ArtistaServiceImpl();
    final CategoriaService categoriaServicio = CategoriaServiceImpl();
    final SalaService salaServicio = SalaServiceImpl();

    final idArtista = obra.idArtista;
    final idSala = obra.idSala;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FICHA DE OBRA',
          style: AppTheme.sans(
            size: 13,
            weight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
      ),
      body: MuseoBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    color: AppTheme.head,
                    child: Image.network(
                      obra.imagenUrl,
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: AppTheme.bronze,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sin vista previa disponible',
                              style: AppTheme.sans(color: AppTheme.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (obra.imagenUrl.isNotEmpty)
                  Align(alignment: Alignment.centerRight, child: TextButton.icon(
                    icon: const Icon(Icons.zoom_in), label: const Text('Inspeccionar obra'),
                    onPressed: () => showDialog<void>(context: context, builder: (dialogo) =>
                      Dialog(child: Column(children: [
                        Align(alignment: Alignment.centerRight, child: IconButton(
                          tooltip: 'Cerrar', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(dialogo))),
                        Expanded(child: InteractiveViewer(minScale: 1, maxScale: 5,
                          child: Image.network(obra.imagenUrl, fit: BoxFit.contain,
                            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                            errorBuilder: (_, _, _) => const Center(child: Text('Imagen no disponible'))))),
                      ]))),
                  )),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FICHA MUSEOGRÁFICA',
                          style: AppTheme.sans(
                            size: 11,
                            weight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: AppTheme.bronze,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          obra.nombre,
                          style: AppTheme.serif(
                            size: 32,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          obra.descripcion,
                          style: AppTheme.sans(
                            size: 15,
                            height: 1.65,
                            color: AppTheme.inkSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estado de conservación',
                              style: AppTheme.sans(
                                weight: FontWeight.w600,
                                size: 13,
                              ),
                            ),
                            Text(
                              '${obra.porcentajeConservacion}%',
                              style: AppTheme.sans(
                                weight: FontWeight.w700,
                                size: 14,
                                color: AppTheme.bronze,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value:
                                obra.porcentajeConservacion.clamp(0, 100) / 100,
                            minHeight: 8,
                            backgroundColor: AppTheme.head,
                            color: AppTheme.bronze,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos catalográficos',
                          style: AppTheme.serif(
                            size: 22,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Divider(height: 24, color: AppTheme.line),
                        if (idArtista == null)
                          _datoFila(
                            Icons.person_outline,
                            'Artista',
                            'Sin artista atribuido',
                          )
                        else
                          FutureBuilder<Artista?>(
                            future: artistaServicio.obtenerArtistaPorId(
                              idArtista,
                            ),
                            builder: (context, snapshot) {
                              final texto =
                                  snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? 'Cargando...'
                                  : (snapshot.data?.nombre ?? 'Desconocido');
                              return _datoFila(
                                Icons.person_outline,
                                'Artista',
                                texto,
                              );
                            },
                          ),
                        FutureBuilder<Categoria?>(
                          future: categoriaServicio.obtenerCategoriaPorId(
                            obra.idCategoria,
                          ),
                          builder: (context, snapshot) {
                            final texto =
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? 'Cargando...'
                                : (snapshot.data?.nombre ?? 'Desconocida');
                            return _datoFila(
                              Icons.category_outlined,
                              'Categoría',
                              texto,
                            );
                          },
                        ),
                        if (idSala == null)
                          _datoFila(
                            Icons.meeting_room_outlined,
                            'Sala actual',
                            'Sin sala asignada',
                          )
                        else
                          FutureBuilder<Sala?>(
                            future: salaServicio.obtenerSalaPorId(idSala),
                            builder: (context, snapshot) {
                              final texto =
                                  snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? 'Cargando...'
                                  : (snapshot.data?.nombre ?? 'Desconocida');
                              return _datoFila(
                                Icons.meeting_room_outlined,
                                'Sala actual',
                                texto,
                              );
                            },
                          ),
                        _datoFila(
                          Icons.calendar_today_outlined,
                          'Año de creación',
                          '${obra.fechaCreacion.year}',
                        ),
                        _datoFila(
                          Icons.inventory_2_outlined,
                          'Año de adquisición',
                          '${obra.fechaAdquisicion.year}',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistorialScreen(obra: obra),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Ver historial de exposición'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _datoFila(IconData icon, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.bronze),
          const SizedBox(width: 12),
          Text(
            '$etiqueta:',
            style: AppTheme.sans(
              weight: FontWeight.w600,
              size: 14,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: AppTheme.sans(weight: FontWeight.w600, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
