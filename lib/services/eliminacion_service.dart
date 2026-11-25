import '../db/connection.dart';

// Los identificadores SQL provienen únicamente de estas definiciones.
enum RegistroMuseo {
  museos('museo', 'id_museo', [
    ('salas_de_exhibición', 'id_museo', 'El museo todavía tiene salas registradas.'),
  ]),
  salas('salas_de_exhibición', 'id_exhibicion', [
    ('artefacto', 'id_exhibicion', 'La sala todavía tiene obras asignadas.'),
    ('exposición_de_artefactos', 'id_exhibicion', 'La sala aparece en el historial de exposición.'),
    ('sala_de_recorrido', 'id_exhibicion', 'La sala pertenece a un recorrido.'),
  ]),
  artistas('artistas', 'id_artistas', [
    ('artefacto', 'id_artistas', 'El artista tiene obras atribuidas.'),
  ]),
  categorias('categoria', 'id_categoria', [
    ('artefacto', 'id_categoria', 'La categoría contiene obras.'),
  ]),
  obras('artefacto', 'id_artefacto', [
    ('exposición_de_artefactos', 'id_artefacto', 'La obra tiene registros en el historial de exposición.'),
  ]),
  recorridos('recorrido', 'id_recorrido', []),
  historial('exposición_de_artefactos', 'id_artefactos_exposicion', []);

  const RegistroMuseo(this.tabla, this.clave, this.referencias);
  final String tabla;
  final String clave;
  final List<(String, String, String)> referencias;

  Future<void> eliminar(int id) => MuseoDatabase.instancia.transaccion((conexion) async {
    final tablaSql = '`$tabla`';
    final fila = await conexion.query(
      'SELECT $clave FROM $tablaSql WHERE $clave = ? FOR UPDATE', [id]);
    if (fila.isEmpty) return;
    for (final (tablaHija, columna, motivo) in referencias) {
      final uso = await conexion.query(
        'SELECT $columna FROM `$tablaHija` WHERE $columna = ? LIMIT 1 FOR UPDATE', [id]);
      if (uso.isNotEmpty) throw RegistroEnUso(motivo);
    }
    if (this == RegistroMuseo.recorridos) {
      await conexion.query('DELETE FROM sala_de_recorrido WHERE id_recorrido = ?', [id]);
    }
    await conexion.query('DELETE FROM $tablaSql WHERE $clave = ?', [id]);
  });
}

class RegistroEnUso implements Exception {
  const RegistroEnUso(this.mensaje);
  final String mensaje;
}