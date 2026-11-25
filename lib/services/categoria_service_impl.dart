import '../db/connection.dart';
import '../models/categoria.dart';
import 'contract/categoria_service.dart';

class CategoriaServiceImpl implements CategoriaService {
  Categoria _mapear(dynamic row) {
    return Categoria(
      id: row['id_categoria'] as int,
      nombre: row['nombre'].toString(),
      descripcion: row['descripcion']?.toString() ?? '',
    );
  }

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_categoria, nombre, descripcion '
      'FROM categoria ORDER BY id_categoria DESC',
    );
    return results.map(_mapear).toList();
  }

  @override
  Future<Categoria?> obtenerCategoriaPorId(int id) async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_categoria, nombre, descripcion '
      'FROM categoria WHERE id_categoria = ?',
      [id],
    );
    if (results.isEmpty) return null;
    return _mapear(results.first);
  }

  @override
  Future<void> registrar(Map<String, String> datos) async {
    await MuseoDatabase.instancia.consultar(
      'INSERT INTO categoria (nombre, descripcion) '
      'VALUES (?, ?)',
      [datos['nombre']!, datos['descripcion']!],
    );
  }
}
