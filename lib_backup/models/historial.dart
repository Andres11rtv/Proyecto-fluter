// Modelo Historial: en qué sala estuvo una obra y entre qué fechas.
// Equivale a la tabla exposicion_de_artefactos.
class Historial {
  final int id;
  final int idObra;
  final int idSala;
  final String fechaInicio;
  final String fechaFin;

  Historial({
    required this.id,
    required this.idObra,
    required this.idSala,
    required this.fechaInicio,
    required this.fechaFin,
  });
}
