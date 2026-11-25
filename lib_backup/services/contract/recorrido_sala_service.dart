import '../../models/recorrido_sala.dart';

abstract class RecorridoSalaService {
  Future<List<RecorridoSala>> obtenerSalasDeRecorrido(int idRecorrido);
}
