import '../db/connection.dart';
import '../models/recorrido.dart';
import 'contract/recorrido_service.dart';

class RecorridoServiceImpl implements RecorridoService {
  static const seleccion =
      'SELECT id_recorrido, nombre, descripcion, CAST(comienza AS CHAR) AS comienza, '
      'CAST(finaliza AS CHAR) AS finaliza, url FROM recorrido';
  final db = MuseoDatabase.instancia;

  Recorrido _mapear(dynamic fila) {
    return Recorrido(
      id: fila['id_recorrido'] as int,
      nombre: fila['nombre'].toString(),
      descripcion: fila['descripcion']?.toString() ?? '',
      comienza: fila['comienza'].toString(),
      finaliza: fila['finaliza'].toString(),
      sitioWeb: fila['url']?.toString() ?? '',
    );
  }

  @override
  Future<List<Recorrido>> obtenerRecorridos() async {
    final filas = await db.consultar('$seleccion ORDER BY id_recorrido DESC');
    return filas.map(_mapear).toList();
  }

  @override
  Future<Recorrido?> obtenerRecorridoPorId(int id) async {
    final filas = await db.consultar('$seleccion WHERE id_recorrido = ?', [id]);
    return filas.isEmpty ? null : _mapear(filas.first);
  }

  @override
  Future<void> registrar(Map<String, String> datos) async {
    // MySQL recibe el horario con horas, minutos y segundos.
    final inicio = datos['comienza']!;
    final fin = datos['finaliza']!;
    await db.transaccion((conexion) async {
      await conexion.query(
        'INSERT INTO recorrido (nombre, descripcion, comienza, finaliza, url) '
        'VALUES (?, ?, ?, ?, ?)',
        [datos['nombre'], datos['descripcion'], inicio.length == 5 ? '$inicio:00' : inicio,
          fin.length == 5 ? '$fin:00' : fin, datos['url']],
      );
      final sala = int.tryParse(datos['sala_inicial']!);
      if (sala != null) {
        await conexion.query(
          'INSERT INTO sala_de_recorrido (id_recorrido, id_exhibicion, numero_de_sequencia) '
          'VALUES (COALESCE(@app_museo_recorrido_insertado, LAST_INSERT_ID()), ?, 1)', [sala],
        );
      }
    });
  }
}
