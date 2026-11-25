import '../db/connection.dart';
import '../models/historial.dart';
import 'contract/historial_service.dart';

class HistorialServiceImpl implements HistorialService {
  Historial _mapear(dynamic row) {
    return Historial(
      id: row['id_artefactos_exposicion'] as int,
      idObra: row['id_artefacto'] as int,
      idSala: row['id_exhibicion'] as int,
      fechaInicio: row['comienza']?.toString() ?? 'Sin registrar',
      fechaFin: row['termina']?.toString() ?? 'Sin registrar',
    );
  }

  @override
  Future<List<Historial>> obtenerHistorial() async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_artefactos_exposicion, id_artefacto, id_exhibicion, CAST(comienza AS CHAR) AS comienza, CAST(termina AS CHAR) AS termina '
      'FROM `exposición_de_artefactos` '
      'ORDER BY id_artefactos_exposicion DESC',
    );
    return results.map(_mapear).toList();
  }

  @override
  Future<List<Historial>> obtenerHistorialPorObra(int idObra) async {
    final results = await MuseoDatabase.instancia.consultar(
      'SELECT id_artefactos_exposicion, id_artefacto, id_exhibicion, CAST(comienza AS CHAR) AS comienza, CAST(termina AS CHAR) AS termina '
      'FROM `exposición_de_artefactos` '
      'WHERE id_artefacto = ? '
      'ORDER BY id_artefactos_exposicion DESC',
      [idObra],
    );
    return results.map(_mapear).toList();
  }
}
