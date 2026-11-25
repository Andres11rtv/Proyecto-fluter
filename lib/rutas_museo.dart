import 'package:flutter/material.dart';
import 'screens/museos_screen.dart';
import 'screens/salas_screen.dart';
import 'screens/artistas_screen.dart';
import 'screens/categorias_screen.dart';
import 'screens/obras_screen.dart';
import 'screens/recorridos_screen.dart';
import 'screens/historial_general_screen.dart';
import 'screens/coleccion_screen.dart';
import 'screens/el_museo_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/museo_detalle_screen.dart';
import 'screens/sala_detalle_screen.dart';
import 'screens/artista_detalle_screen.dart';
import 'screens/categoria_detalle_screen.dart';
import 'screens/obra_detalle_screen.dart';
import 'screens/recorrido_detalle_screen.dart';
import 'services/museo_service_impl.dart';
import 'services/sala_service_impl.dart';
import 'services/artista_service_impl.dart';
import 'services/categoria_service_impl.dart';
import 'services/obra_service_impl.dart';
import 'services/recorrido_service_impl.dart';
// Una ruta normal utiliza los datos ya cargados. F5 reconstruye la ficha por ID.
MaterialPageRoute<void> rutaMuseo(Widget pagina) {
  final nombre = switch (pagina) {
    MuseosScreen() => '/museos',
    SalasScreen() => '/salas',
    ArtistasScreen() => '/artistas',
    CategoriasScreen() => '/categorias',
    ObrasScreen(:final busquedaInicial) => Uri(path: '/obras', queryParameters: busquedaInicial.isEmpty ? null : {'q': busquedaInicial}).toString(),
    RecorridosScreen() => '/recorridos',
    HistorialGeneralScreen() => '/historial',
    ColeccionScreen(:final busquedaInicial) => Uri(path: '/coleccion', queryParameters: busquedaInicial.isEmpty ? null : {'q': busquedaInicial}).toString(),
    ElMuseoScreen() => '/el-museo',
    MuseoDetalleScreen(:final museo) => '/museos/${museo.id}',
    SalaDetalleScreen(:final sala) => '/salas/${sala.id}',
    ArtistaDetalleScreen(:final artista) => '/artistas/${artista.id}',
    CategoriaDetalleScreen(:final categoria) => '/categorias/${categoria.id}',
    ObraDetalleScreen(:final obra) => '/obras/${obra.id}',
    RecorridoDetalleScreen(:final recorrido) => '/recorridos/${recorrido.id}',
    HistorialScreen(:final obra) => '/obras/${obra.id}/historial',
    _ => null,
  };
  return MaterialPageRoute<void>(settings: RouteSettings(name: nombre), builder: (_) => pagina);
}

Route<dynamic>? restaurarRutaMuseo(RouteSettings ajustes) {
  final uri = Uri.tryParse(ajustes.name ?? '');
  if (uri == null) return null;
  final partes = uri.pathSegments;
  Widget? pagina;
  if (partes.length == 1) {
    pagina = switch (uri.path) {
      '/museos' => const MuseosScreen(),
      '/salas' => const SalasScreen(),
      '/artistas' => const ArtistasScreen(),
      '/categorias' => const CategoriasScreen(),
      '/obras' => ObrasScreen(busquedaInicial: uri.queryParameters['q'] ?? ''),
      '/recorridos' => const RecorridosScreen(),
      '/historial' => const HistorialGeneralScreen(),
      '/coleccion' => ColeccionScreen(busquedaInicial: uri.queryParameters['q'] ?? ''),
      '/el-museo' => const ElMuseoScreen(),
      _ => null,
    };
  } else if (partes.length >= 2) {
    final id = int.tryParse(partes[1]);
    if (id == null) return null;
    if (partes.length == 2) {
      pagina = switch (partes.first) {
        'museos' => _RegistroPorId(cargar: () async {
          final dato = await MuseoServiceImpl().obtenerMuseoPorId(id);
          return dato == null ? null : MuseoDetalleScreen(museo: dato);
        }),
        'salas' => _RegistroPorId(cargar: () async {
          final dato = await SalaServiceImpl().obtenerSalaPorId(id);
          return dato == null ? null : SalaDetalleScreen(sala: dato);
        }),
        'artistas' => _RegistroPorId(cargar: () async {
          final dato = await ArtistaServiceImpl().obtenerArtistaPorId(id);
          return dato == null ? null : ArtistaDetalleScreen(artista: dato);
        }),
        'categorias' => _RegistroPorId(cargar: () async {
          final dato = await CategoriaServiceImpl().obtenerCategoriaPorId(id);
          return dato == null ? null : CategoriaDetalleScreen(categoria: dato);
        }),
        'obras' => _RegistroPorId(cargar: () async {
          final dato = await ObraServiceImpl().obtenerObraPorId(id);
          return dato == null ? null : ObraDetalleScreen(obra: dato);
        }),
        'recorridos' => _RegistroPorId(cargar: () async {
          final dato = await RecorridoServiceImpl().obtenerRecorridoPorId(id);
          return dato == null ? null : RecorridoDetalleScreen(recorrido: dato);
        }),
        _ => null,
      };
    } else if (partes.length == 3 && partes.first == 'obras' && partes.last == 'historial') {
      pagina = _RegistroPorId(cargar: () async {
        final obra = await ObraServiceImpl().obtenerObraPorId(id);
        return obra == null ? null : HistorialScreen(obra: obra);
      });
    } else if (partes.length == 3 && partes.first == 'recorridos' && partes.last == 'visita') {
      pagina = _RegistroPorId(cargar: () => recuperarVisitaMuseo(id));
    }
  }
  final destino = pagina;
  if (destino == null) return null;
  return MaterialPageRoute<void>(settings: ajustes, builder: (_) => destino);
}

class _RegistroPorId extends StatefulWidget {
  const _RegistroPorId({required this.cargar});
  final Future<Widget?> Function() cargar;
  @override
  State<_RegistroPorId> createState() => _RegistroPorIdState();
}

class _RegistroPorIdState extends State<_RegistroPorId> {
  late Future<Widget?> consulta = widget.cargar();
  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
    future: consulta,
    builder: (_, estado) {
      if (estado.connectionState == ConnectionState.done && estado.hasData) {
        return estado.data!;
      }
      return Scaffold(appBar: AppBar(), body: Center(child:
        estado.connectionState != ConnectionState.done ? const CircularProgressIndicator() :
        estado.hasError ? TextButton(
          onPressed: () => setState(() { consulta = widget.cargar(); }),
          child: const Text('No se pudo cargar. Reintentar'),
        ) : const Text('Este registro ya no está disponible.')));
    },
  );
}
