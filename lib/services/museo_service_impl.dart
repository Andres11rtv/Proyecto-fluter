import '../db/connection.dart';
import '../models/museo.dart';
import 'contract/museo_service.dart';

class MuseoServiceImpl implements MuseoService {
  Museo _mapear(dynamic row) {
    return Museo(
      id: row['id_museo'] as int,
      nombre: row['nombre'].toString(),
      descripcion: row['descripcion']?.toString() ?? '',
      latitud: (row['latitud'] as num).toDouble(),
      longitud: (row['longitud'] as num).toDouble(),
      sitioWeb: row['url']?.toString() ?? '',
    );
  }

  @override
  Future<List<Museo>> obtenerMuseos() async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_museo, nombre, descripcion, latitud, longitud, url '
      'FROM museo ORDER BY id_museo DESC',
    );
    return results.map(_mapear).toList();
  }

  @override
  Future<Museo?> obtenerMuseoPorId(int id) async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_museo, nombre, descripcion, latitud, longitud, url '
      'FROM museo WHERE id_museo = ?',
      [id],
    );
    if (results.isEmpty) return null;
    return _mapear(results.first);
  }

  @override
  Future<void> registrar(Map<String, String> datos) async {
    await MuseoDatabase.instancia.consultar(
      'INSERT INTO museo (nombre, descripcion, latitud, longitud, url) '
      'VALUES (?, ?, ?, ?, ?)',
      [datos['nombre']!, datos['descripcion']!, datos['latitud']!, datos['longitud']!, datos['url']!],
    );
  }
}
