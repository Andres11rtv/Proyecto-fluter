import 'package:mysql2/mysql2.dart';

final _settings = ConnectionSettings(
  host: '127.0.0.1',
  port: 3307, // Puerto real de tu XAMPP
  user: 'root',
  password: null,
  db: 'museos',
  bridgeUrl: 'ws://localhost:8080/mysql',
  bridgeToken: 'qwertyuiopasdfghjklñzxcvbnmqwertyuiop'
);

class MuseoDatabase {
  MuseoDatabase._();

  static final MuseoDatabase instancia = MuseoDatabase._();

  MySqlConnection? _conexion;
  Future<void> _turno = Future<void>.value();

  Future<Iterable<ResultRow>> consultar(String sql, [List<dynamic>? parametros]) {
    // Las consultas comparten una conexion y se ejecutan en orden.
    final consulta = _turno.then((_) => _ejecutar(sql, parametros));
    _turno = consulta.then<void>((_) {}, onError: (Object error, StackTrace traza) {});
    return consulta;
  }

  Future<Iterable<ResultRow>> _ejecutar(String sql, List<dynamic>? parametros) async {
    final conexion = _conexion ??= await MySqlConnection.connect(_settings);
    try {
      return await conexion.query(sql, parametros);
    } catch (_) {
      _conexion = null;
      try {
        await conexion.close();
      } catch (_) {
        // La conexion puede haberse cerrado al interrumpirse.
      }
      rethrow;
    }
  }


  // Reserva la conexión hasta que se confirmen todos los cambios relacionados.
  Future<void> transaccion(Future<void> Function(MySqlConnection) operacion) {
    final tarea = _turno.then((_) async {
      final conexion = _conexion ??= await MySqlConnection.connect(_settings);
      try {
        await conexion.query('START TRANSACTION');
        await operacion(conexion);
        await conexion.query('COMMIT');
      } catch (_) {
        try {
          await conexion.query('ROLLBACK');
        } catch (_) {
          _conexion = null;
          try {
            await conexion.close();
          } catch (_) {
            // La conexión ya puede estar cerrada.
          }
        }
        rethrow;
      }
    });
    _turno = tarea.then<void>((_) {}, onError: (Object error, StackTrace traza) {});
    return tarea;
  }
}
