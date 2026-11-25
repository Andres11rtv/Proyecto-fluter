import '../../models/museo.dart';

abstract class MuseoService {
  Future<List<Museo>> obtenerMuseos();
  Future<Museo?> obtenerMuseoPorId(int id);
  Future<void> registrar(Map<String, String> datos);
}
