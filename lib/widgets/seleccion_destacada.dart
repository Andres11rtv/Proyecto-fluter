import '../models/obra.dart';

// El catálogo proporciona las fichas. Esta lista decide cuáles exhibir en portada.
const fotosDestacadas = {
  'la noche estrellada': 'assets/destacadas/noche.jpg',
  'el pensador': 'assets/destacadas/pensador.jpg',
};

List<Obra> obrasDestacadas(List<Obra> catalogo) {
  final porTitulo = {for (final obra in catalogo) obra.nombre.trim().toLowerCase(): obra};
  return [
    for (final titulo in fotosDestacadas.keys)
      if (porTitulo[titulo] != null) porTitulo[titulo]!,
  ];
}
