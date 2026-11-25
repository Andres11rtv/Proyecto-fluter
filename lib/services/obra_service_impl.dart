import '../db/connection.dart';
import '../models/obra.dart';
import 'contract/obra_service.dart';

class ObraServiceImpl implements ObraService {
  DateTime _aDateTime(dynamic valor) {
    if (valor is DateTime) return valor;
    return DateTime.parse(valor.toString());
  }

  Obra _mapear(dynamic row) {
    return Obra(
      id: row['id_artefacto'] as int,
      nombre: row['nombre'].toString(),
      descripcion: row['descripcion']?.toString() ?? '',
      imagenUrl: row['imagen_url']?.toString() ?? '',
      fechaCreacion: _aDateTime(row['creacion']),
      fechaAdquisicion: _aDateTime(row['adquisicion']),
      porcentajeConservacion: row['porcentaje_de_condicion'] as int,
      idCategoria: row['id_categoria'] as int,
      idArtista: row['id_artistas'] as int?,
      idSala: row['id_exhibicion'] as int?,
    );
  }

  @override
  Future<List<Obra>> obtenerObras() async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_artefacto, nombre, descripcion, imagen_url, creacion, '
      'adquisicion, porcentaje_de_condicion, id_categoria, id_artistas, id_exhibicion '
      'FROM artefacto ORDER BY id_artefacto DESC',
    );
    return results.map(_mapear).toList();
  }

  @override
  Future<Obra?> obtenerObraPorId(int id) async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_artefacto, nombre, descripcion, imagen_url, creacion, '
      'adquisicion, porcentaje_de_condicion, id_categoria, id_artistas, id_exhibicion '
      'FROM artefacto WHERE id_artefacto = ?',
      [id],
    );
    if (results.isEmpty) return null;
    return _mapear(results.first);
  }

  @override
  Future<void> registrar(Map<String, String> datos) async {
    await MuseoDatabase.instancia.consultar(
      'INSERT INTO artefacto (nombre, descripcion, imagen_url, creacion, adquisicion, porcentaje_de_condicion, id_categoria, id_artistas, id_exhibicion) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [datos['nombre']!, datos['descripcion']!, datos['imagen_url']!, datos['creacion']!, datos['adquisicion']!, datos['porcentaje_de_condicion']!, datos['id_categoria']!, int.tryParse(datos['id_artistas']!), int.tryParse(datos['id_exhibicion']!)],
    );
  }
}
