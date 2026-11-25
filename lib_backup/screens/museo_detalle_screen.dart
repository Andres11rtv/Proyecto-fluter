import '../widgets/ficha_museo.dart';
import 'package:flutter/material.dart';
import '../models/museo.dart';
import '../models/sala.dart';
import '../services/contract/sala_service.dart';
import '../services/sala_service_impl.dart';
import 'sala_detalle_screen.dart';

class MuseoDetalleScreen extends StatelessWidget {
  final Museo museo;

  const MuseoDetalleScreen({super.key, required this.museo});

  @override
  Widget build(BuildContext context) {
    final SalaService salaServicio = SalaServiceImpl();

    return FichaMuseo(
      titulo: museo.nombre,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(museo.descripcion),
          const SizedBox(height: 16),
          Text('Latitud: ${museo.latitud}'),
          Text('Longitud: ${museo.longitud}'),
          Text('Sitio web: ${museo.sitioWeb}'),
          const SizedBox(height: 24),
          Text(
            'Salas de exposición',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Sala>>(
            future: salaServicio.obtenerSalas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Error al cargar las salas');
              }
              final salas = (snapshot.data ?? [])
                  .where((s) => s.idMuseo == museo.id)
                  .toList();
              if (salas.isEmpty) {
                return const Text('Sin salas');
              }
              return Column(
                children: [
                  for (final sala in salas)
                    ListTile(
                      title: Text(sala.nombre),
                      subtitle: Text('Capacidad: ${sala.capacidad}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SalaDetalleScreen(sala: sala),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
