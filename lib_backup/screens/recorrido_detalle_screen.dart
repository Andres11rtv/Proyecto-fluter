import '../widgets/ficha_museo.dart';
import 'sala_detalle_screen.dart';
import 'package:flutter/material.dart';
import '../models/recorrido.dart';
import '../models/recorrido_sala.dart';
import '../models/sala.dart';
import '../services/contract/recorrido_sala_service.dart';
import '../services/recorrido_sala_service_impl.dart';
import '../services/contract/sala_service.dart';
import '../services/sala_service_impl.dart';

// Detalle de un recorrido con sus salas en orden de visita.
// Uso: RecorridoDetalleScreen(recorrido: recorrido)
class RecorridoDetalleScreen extends StatelessWidget {
  final Recorrido recorrido;

  const RecorridoDetalleScreen({super.key, required this.recorrido});

  @override
  Widget build(BuildContext context) {
    final RecorridoSalaService recorridoSalaServicio = RecorridoSalaServiceImpl();
    final SalaService salaServicio = SalaServiceImpl();

    return FichaMuseo(
      titulo: recorrido.nombre,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              recorrido.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Horario: ${recorrido.comienza} – ${recorrido.finaliza}'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Salas del recorrido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RecorridoSala>>(
              future: recorridoSalaServicio.obtenerSalasDeRecorrido(recorrido.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar las salas'));
                }
                final salas = snapshot.data ?? [];
                if (salas.isEmpty) {
                  return const Center(child: Text('Este recorrido no tiene salas'));
                }
                return Column(children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.route), label: const Text('Iniciar visita guiada'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => _VisitaGuiada(titulo: recorrido.nombre, paradas: salas),
                    )),
                  ),
                  Expanded(child: ListView.builder(
                  itemCount: salas.length,
                  itemBuilder: (context, index) {
                    final item = salas[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${item.numeroOrden}')),
                      title: FutureBuilder<Sala?>(
                        future: salaServicio.obtenerSalaPorId(item.idSala),
                        builder: (context, snapshotSala) {
                          if (snapshotSala.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Cargando sala...');
                          }
                          final sala = snapshotSala.data;
                          if (sala == null) {
                            return const Text('Sala desconocida');
                          }
                          return TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => SalaDetalleScreen(sala: sala),
                            )),
                            child: Text(sala.nombre),
                          );
                        },
                      ),
                    );
                  },
                  )),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _VisitaGuiada extends StatefulWidget {
  final String titulo;
  final List<RecorridoSala> paradas;
  const _VisitaGuiada({required this.titulo, required this.paradas});

  @override
  State<_VisitaGuiada> createState() => _VisitaGuiadaState();
}

class _VisitaGuiadaState extends State<_VisitaGuiada> {
  final servicio = SalaServiceImpl();
  int indice = 0;
  late Future<Sala?> sala = servicio.obtenerSalaPorId(widget.paradas.first.idSala);

  void ir(int posicion) {
    setState(() {
      indice = posicion;
      sala = servicio.obtenerSalaPorId(widget.paradas[posicion].idSala);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FichaMuseo(titulo: widget.titulo, body: ListView(
      padding: const EdgeInsets.all(24), children: [
        Text('Parada ${indice + 1} de ${widget.paradas.length}'),
        const SizedBox(height: 16),
        FutureBuilder<Sala?>(future: sala, builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
          final actual = snapshot.data;
          if (snapshot.hasError || actual == null) return const Text('Sala no disponible.');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(actual.nombre, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12), Text(actual.descripcion),
          ]);
        }),
        const SizedBox(height: 24),
        Wrap(spacing: 12, children: [
          OutlinedButton(onPressed: indice > 0 ? () => ir(indice - 1) : null, child: const Text('Anterior')),
          if (indice + 1 < widget.paradas.length)
            FilledButton(onPressed: () => ir(indice + 1), child: const Text('Siguiente'))
          else
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Terminar visita')),
        ]),
      ],
    ));
  }
}
