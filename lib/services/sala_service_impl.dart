import '../db/connection.dart';
import '../models/sala.dart';
import 'contract/sala_service.dart';

class SalaServiceImpl implements SalaService {
  Sala _mapear(dynamic row) {
    return Sala(
      id: row['id_exhibicion'] as int,
      idMuseo: row['id_museo'] as int,
      nombre: row['nombre'].toString(),
      descripcion: row['descripcion']?.toString() ?? '',
      capacidad: row['capacidad'] as int,
    );
  }

  @override
  Future<List<Sala>> obtenerSalas() async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_exhibicion, id_museo, nombre, descripcion, capacidad '
      'FROM `salas_de_exhibición` ORDER BY id_exhibicion DESC',
    );
    return results.map(_mapear).toList();
  }

  @override
  Future<Sala?> obtenerSalaPorId(int id) async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_exhibicion, id_museo, nombre, descripcion, capacidad '
      'FROM `salas_de_exhibición` WHERE id_exhibicion = ?',
      [id],
    );
    if (results.isEmpty) return null;
    return _mapear(results.first);
  }

  @override
  Future<void> registrar(Map<String, String> datos) async {
    await MuseoDatabase.instancia.consultar(
      'INSERT INTO `salas_de_exhibición` (nombre, descripcion, capacidad, id_museo) '
      'VALUES (?, ?, ?, ?)',
      [datos['nombre']!, datos['descripcion']!, datos['capacidad']!, datos['id_museo']!],
    );
  }
}
