import '../widgets/ficha_museo.dart';
import 'package:flutter/material.dart';
import '../models/sala.dart';
import '../models/obra.dart';
import '../services/contract/obra_service.dart';
import '../services/obra_service_impl.dart';
import 'obra_detalle_screen.dart';

class SalaDetalleScreen extends StatelessWidget {
  final Sala sala;

  const SalaDetalleScreen({super.key, required this.sala});

  @override
  Widget build(BuildContext context) {
    final ObraService obraServicio = ObraServiceImpl();

    return FichaMuseo(
      titulo: sala.nombre,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(sala.descripcion),
          const SizedBox(height: 16),
          Text('Capacidad: ${sala.capacidad} personas'),
          const SizedBox(height: 24),
          Text(
            'Obras en esta sala',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Obra>>(
            future: obraServicio.obtenerObras(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Error al cargar las obras');
              }
              final obras = (snapshot.data ?? [])
                  .where((o) => o.idSala == sala.id)
                  .toList();
              if (obras.isEmpty) {
                return const Text('Sin obras');
              }
              return Column(
                children: [
                  for (final obra in obras)
                    ListTile(
                      title: Text(obra.nombre),
                      subtitle: Text(obra.descripcion),
                      trailing: Text('${obra.porcentajeConservacion}%'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ObraDetalleScreen(obra: obra),
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
