import '../db/connection.dart';
import '../models/artista.dart';
import 'contract/artista_service.dart';

class ArtistaServiceImpl implements ArtistaService {
  Artista _mapear(dynamic row) {
    return Artista(
      id: row['id_artistas'] as int,
      nombre: row['nombre'].toString(),
      biografia: row['biografia']?.toString() ?? '',
      nacionalidad: row['nacionalidad']?.toString() ?? '',
    );
  }

  @override
  Future<List<Artista>> obtenerArtistas() async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_artistas, nombre, biografia, nacionalidad '
      'FROM artistas ORDER BY id_artistas DESC',
    );
    return results.map(_mapear).toList();
  }

  @override
  Future<Artista?> obtenerArtistaPorId(int id) async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_artistas, nombre, biografia, nacionalidad '
      'FROM artistas WHERE id_artistas = ?',
      [id],
    );
    if (results.isEmpty) return null;
    return _mapear(results.first);
  }

  @override
  Future<void> agregarArtista(Artista artista) async {
    await registrar({
      'nombre': artista.nombre,
      'biografia': artista.biografia,
      'nacionalidad': artista.nacionalidad,
    });
  }

  @override
  Future<void> registrar(Map<String, String> datos) async {
    await MuseoDatabase.instancia.consultar(
      'INSERT INTO artistas (nombre, biografia, nacionalidad) VALUES (?, ?, ?)',
      [datos['nombre'], datos['biografia'], datos['nacionalidad']],
    );
  }
}
