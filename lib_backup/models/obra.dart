class Obra {
  final int id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final DateTime fechaCreacion;
  final DateTime fechaAdquisicion;
  final int porcentajeConservacion;
  final int idCategoria;
  final int? idArtista; 
  final int? idSala;    

  Obra({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.fechaCreacion,
    required this.fechaAdquisicion,
    required this.porcentajeConservacion,
    required this.idCategoria,
    this.idArtista,
    this.idSala,
  });
}