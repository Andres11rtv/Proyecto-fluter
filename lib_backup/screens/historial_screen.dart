import '../widgets/ficha_museo.dart';
import 'package:flutter/material.dart';
import '../models/obra.dart';
import '../models/historial.dart';
import '../models/sala.dart';
import '../services/contract/historial_service.dart';
import '../services/historial_service_impl.dart';
import '../services/contract/sala_service.dart';
import '../services/sala_service_impl.dart';

// Muestra en qué salas ha estado una obra y entre qué fechas.
// Uso: HistorialScreen(obra: obra)
class HistorialScreen extends StatelessWidget {
  final Obra obra;

  const HistorialScreen({super.key, required this.obra});

  @override
  Widget build(BuildContext context) {
    final HistorialService historialServicio = HistorialServiceImpl();
    final SalaService salaServicio = SalaServiceImpl();

    return FichaMuseo(
      titulo: 'Historial de ${obra.nombre}',
      body: FutureBuilder<List<Historial>>(
        future: historialServicio.obtenerHistorialPorObra(obra.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el historial'));
          }
          final registros = snapshot.data ?? [];
          if (registros.isEmpty) {
            return const Center(child: Text('Esta obra no tiene historial'));
          }
          return ListView.builder(
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final registro = registros[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.meeting_room),
                  title: FutureBuilder<Sala?>(
                    future: salaServicio.obtenerSalaPorId(registro.idSala),
                    builder: (context, snapshotSala) {
                      if (snapshotSala.connectionState ==
                          ConnectionState.waiting) {
                        return const Text('Cargando sala...');
                      }
                      final sala = snapshotSala.data;
                      if (sala == null) {
                        return const Text('Sala desconocida');
                      }
                      return Text(sala.nombre);
                    },
                  ),
                  subtitle: Text(
                    'Inicio: ${registro.fechaInicio}\n'
                    'Fin: ${registro.fechaFin}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
