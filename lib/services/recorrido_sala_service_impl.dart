import '../db/connection.dart';
import '../models/recorrido_sala.dart';
import 'contract/recorrido_sala_service.dart';

class RecorridoSalaServiceImpl implements RecorridoSalaService {
  @override
  Future<List<RecorridoSala>> obtenerSalasDeRecorrido(int idRecorrido) async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_recorrido, id_exhibicion, numero_de_sequencia '
      'FROM sala_de_recorrido '
      'WHERE id_recorrido = ? '
      'ORDER BY numero_de_sequencia ASC',
      [idRecorrido],
    );
    return results
        .map(
          (row) => RecorridoSala(
            idRecorrido: row['id_recorrido'] as int,
            idSala: row['id_exhibicion'] as int,
            numeroOrden: row['numero_de_sequencia'] as int,
          ),
        )
        .toList();
  }
}