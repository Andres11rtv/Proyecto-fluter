import 'package:flutter/material.dart';
import '../services/eliminacion_service.dart';

class PapeleraRegistro extends StatefulWidget {
  const PapeleraRegistro({super.key, required this.tipo, required this.id,
    required this.nombre, required this.alEliminar});

  final RegistroMuseo tipo;
  final int id;
  final String nombre;
  final VoidCallback alEliminar;

  @override
  State<PapeleraRegistro> createState() => _PapeleraRegistroState();
}

class _PapeleraRegistroState extends State<PapeleraRegistro> {
  bool ocupado = false;

  Future<void> confirmar() async {
    if (ocupado) return;
    final tipo = widget.tipo;
    final id = widget.id;
    final nombre = widget.nombre;
    final refrescar = widget.alEliminar;
    final avisos = ScaffoldMessenger.of(context);
    setState(() => ocupado = true);
    try {
      final acepta = await showDialog<bool>(context: context, builder: (dialogo) =>
        AlertDialog(
          title: const Text('¿Eliminar este registro?'),
          content: Text('Se eliminará «$nombre» de forma permanente.'
            '${tipo == RegistroMuseo.recorridos ? " También se quitarán sus paradas del itinerario. Las salas se conservarán." : ""}'),
          actions: [
            TextButton(autofocus: true, onPressed: () => Navigator.pop(dialogo, false),
              child: const Text('Cancelar')),
            FilledButton(style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogo).colorScheme.error,
              foregroundColor: Theme.of(dialogo).colorScheme.onError),
              onPressed: () => Navigator.pop(dialogo, true), child: const Text('Eliminar')),
          ],
        ));
      if (acepta != true || !mounted) return;
      await tipo.eliminar(id);
      refrescar();
      if (avisos.mounted) avisos.showSnackBar(SnackBar(content: Text('Registro eliminado: $nombre')));
    } on RegistroEnUso catch (e) {
      if (avisos.mounted) avisos.showSnackBar(SnackBar(content: Text(e.mensaje)));
    } catch (e) {
            debugPrint('Error de borrado ($tipo, id $id): $e');
      refrescar();
      final relacionado = RegExp(r'1451|foreign key', caseSensitive: false).hasMatch(e.toString());
      if (avisos.mounted) {
        avisos.showSnackBar(SnackBar(content: Text(relacionado
        ? 'Otro registro utiliza este dato. Revisa sus relaciones antes de eliminarlo.'
        : 'No se pudo confirmar la eliminación. Actualiza la lista y revisa la conexión.')));
      }
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Eliminar ${widget.nombre}', onPressed: ocupado ? null : confirmar,
    color: Theme.of(context).colorScheme.error,
    icon: const Icon(Icons.delete_outline_rounded, size: 21),
  );
}