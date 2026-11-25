import '../../models/historial.dart';

abstract class HistorialService {
  Future<List<Historial>> obtenerHistorial();
  Future<List<Historial>> obtenerHistorialPorObra(int idObra);
}
