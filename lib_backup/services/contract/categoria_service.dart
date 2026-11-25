import '../../models/categoria.dart';

abstract class CategoriaService {
  Future<List<Categoria>> obtenerCategorias();
  Future<Categoria?> obtenerCategoriaPorId(int id);
  Future<void> registrar(Map<String, String> datos);
}
