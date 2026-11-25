import 'registro_screen.dart';
import 'package:flutter/material.dart';
import '../models/artista.dart';
import '../services/contract/artista_service.dart';
import '../services/contract/categoria_service.dart';
import '../services/contract/obra_service.dart';
import '../services/artista_service_impl.dart';
import '../services/categoria_service_impl.dart';
import '../services/obra_service_impl.dart';
import '../widgets/admin_widgets.dart';
import 'artista_detalle_screen.dart';

class ArtistasScreen extends StatelessWidget {
  const ArtistasScreen({super.key});

  Future<AdminDatos<Artista>> _cargar() async {
    final ArtistaService artistaServicio = ArtistaServiceImpl();
    final CategoriaService categoriaServicio = CategoriaServiceImpl();
    final ObraService obraServicio = ObraServiceImpl();
    final artistas = await artistaServicio.obtenerArtistas();
    final categorias = await categoriaServicio.obtenerCategorias();
    final obras = await obraServicio.obtenerObras();
    final atribuidas = obras.where((o) => o.idArtista != null).length;

    return AdminDatos<Artista>(
      items: artistas,
      idRegistro: (item) => item.id, nombreRegistro: (item) => item.nombre,
      kpis: [
        KpiDato('Artistas registrados', '${artistas.length}'),
        KpiDato('Colecciones', '${categorias.length}'),
        KpiDato('Obras atribuidas', '$atribuidas'),
      ],
      campos: [
        const CampoRegistro('nombre', 'Nombre completo', obligatorio: true),
        const CampoRegistro('nacionalidad', 'Nacionalidad'),
        const CampoRegistro('biografia', 'Biografía', lineas: 3),
      ],
      guardar: artistaServicio.registrar,
      textoBusqueda: (a) => '${a.nombre} ${a.nacionalidad} ${a.biografia}',
      celdas: (a) => [
        AdminCeldas.titulo(a.nombre),
        AdminCeldas.texto(a.nacionalidad),
      ],
      detalle: (a) => ArtistaDetalleScreen(artista: a),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminListPage<Artista>(
      activeId: 'artistas',
      titulo: 'Gestión de artistas',
      subtitulo: 'Registra los autores, sus biografías y nacionalidades para vincularlos a las obras.',
      textoNuevo: 'Nuevo artista',
      hintBusqueda: 'Buscar artistas...',
      tituloForm: 'Datos del artista',
      columnas: const ['Nombre', 'Nacionalidad'],
      cargar: _cargar,
    );
  }
}
