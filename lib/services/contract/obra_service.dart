import '../../models/obra.dart';

abstract class ObraService {
  Future<List<Obra>> obtenerObras();
  Future<Obra?> obtenerObraPorId(int id);
  Future<void> registrar(Map<String, String> datos);
}
