import '../../models/recorrido.dart';

abstract class RecorridoService {
  Future<List<Recorrido>> obtenerRecorridos();
  Future<Recorrido?> obtenerRecorridoPorId(int id);
  Future<void> registrar(Map<String, String> datos);
}
