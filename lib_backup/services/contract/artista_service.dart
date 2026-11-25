import '../../models/artista.dart';

abstract class ArtistaService {
  Future<List<Artista>> obtenerArtistas();
  Future<Artista?> obtenerArtistaPorId(int id);
  Future<void> agregarArtista(Artista artista);
  Future<void> registrar(Map<String, String> datos);
}
