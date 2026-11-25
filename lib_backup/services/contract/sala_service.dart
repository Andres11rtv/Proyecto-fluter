import '../../models/sala.dart';

abstract class SalaService {
  Future<List<Sala>> obtenerSalas();
  Future<Sala?> obtenerSalaPorId(int id);
  Future<void> registrar(Map<String, String> datos);
}
