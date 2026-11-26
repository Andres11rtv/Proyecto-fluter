import '../rutas_museo.dart';
import '../widgets/vidrio_portada.dart';
import '../widgets/imagen_obra.dart';
import '../widgets/seleccion_destacada.dart';

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
    TemaMuseoActivo.observar(context);
    final ArtistaService artistaServicio = ArtistaServiceImpl();
    final CategoriaService categoriaServicio = CategoriaServiceImpl();
    final SalaService salaServicio = SalaServiceImpl();

    final idArtista = obra.idArtista;
    final idSala = obra.idSala;

    final imagen = ImagenObra(
      url: obra.imagenUrl,
      nombre: obra.nombre,
      ajuste: BoxFit.contain,
    );
    final sePuedeAmpliar =
        obra.imagenUrl.trim().isNotEmpty ||
        (fotosDestacadas.containsKey(obra.nombre.trim().toLowerCase()) || ImagenObra.fotosDeCatalogo.containsKey(obra.nombre.trim().toLowerCase()));

    final galeria = VidrioPortada(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: AppTheme.head,
                child: AspectRatio(
                  aspectRatio: 1.22,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: imagen,
                  ),
                ),
              ),
            ),
            if (sePuedeAmpliar)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.zoom_in_rounded),
                  label: const Text('Inspeccionar obra'),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogo) => Dialog(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: CloseButton(
                              onPressed: () => Navigator.pop(dialogo),
                            ),
                          ),
                          Expanded(
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 5,
                              child: SizedBox.expand(child: imagen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final ficha = VidrioPortada(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              obra.nombre,
              style: AppTheme.serif(
                size: 38,
                weight: FontWeight.w600,
                height: 1.1,
              ),
            ),
            if (obra.descripcion.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                obra.descripcion,
                style: AppTheme.sans(size: 15, height: 1.55),
              ),
            ],
            Divider(height: 32, color: AppTheme.line),
            Text('Datos catalográficos', style: AppTheme.serif(size: 24)),
            const SizedBox(height: 8),
            if (idArtista == null)
              _datoFila(
                Icons.person_outline,
                'Artista',
                'Sin artista atribuido',
              )
            else
              FutureBuilder<Artista?>(
                future: artistaServicio.obtenerArtistaPorId(idArtista),
                builder: (context, snapshot) {
                  final texto =
                      snapshot.connectionState == ConnectionState.waiting
                      ? 'Cargando...'
                      : (snapshot.data?.nombre ?? 'Desconocido');
                  return _datoFila(Icons.person_outline, 'Artista', texto);
                },
              ),
            FutureBuilder<Categoria?>(
              future: categoriaServicio.obtenerCategoriaPorId(obra.idCategoria),
              builder: (context, snapshot) {
                final texto =
                    snapshot.connectionState == ConnectionState.waiting
                    ? 'Cargando...'
                    : (snapshot.data?.nombre ?? 'Desconocida');
                return _datoFila(Icons.category_outlined, 'Categoría', texto);
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
                      snapshot.connectionState == ConnectionState.waiting
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
            Divider(height: 28, color: AppTheme.line),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              children: [
                Text('Estado de conservación', style: AppTheme.sans(size: 14)),
                Text(
                  '${obra.porcentajeConservacion}%',
                  style: AppTheme.sans(
                    color: AppTheme.bronze,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(6),
              minHeight: 6,
              color: AppTheme.bronze,
              backgroundColor: AppTheme.head,
              value: obra.porcentajeConservacion.clamp(0, 100) / 100,
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Ver historial de exposición'),
                onPressed: () => Navigator.push(
                  context,
                  rutaMuseo(HistorialScreen(obra: obra)),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: MuseoBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VidrioPortada(
                        radio: 30,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const BackButton(),
                              const SizedBox(width: 8),
                              Text(
                                'Ficha de obra',
                                style: AppTheme.serif(size: 23),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (_, limites) {
                          if (limites.maxWidth < 800) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                galeria,
                                const SizedBox(height: 16),
                                ficha,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: galeria),
                              const SizedBox(width: 20),
                              Expanded(flex: 4, child: ficha),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datoFila(IconData icon, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppTheme.bronze),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              etiqueta,
              style: AppTheme.sans(size: 13, color: AppTheme.muted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              valor,
              style: AppTheme.sans(size: 14, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
