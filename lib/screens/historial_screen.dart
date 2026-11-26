import 'package:flutter/material.dart';

import '../models/historial.dart';
import '../models/obra.dart';
import '../models/sala.dart';
import '../services/historial_service_impl.dart';
import '../services/sala_service_impl.dart';
import '../theme/app_theme.dart';
import '../widgets/imagen_obra.dart';
import '../widgets/vidrio_portada.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key, required this.obra});

  final Obra obra;

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final historial = HistorialServiceImpl();
  final salas = SalaServiceImpl();
  final nombres = <int, Future<Sala?>>{};
  late Future<List<Historial>> registros;

  @override
  void initState() {
    super.initState();
    registros = historial.obtenerHistorialPorObra(widget.obra.id);
  }

  @override
  void didUpdateWidget(HistorialScreen anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.obra.id != widget.obra.id) {
      nombres.clear();
      registros = historial.obtenerHistorialPorObra(widget.obra.id);
    }
  }

  Widget horario(String etiqueta, String valor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: AppTheme.sans(size: 13, color: AppTheme.muted)),
        const SizedBox(height: 3),
        Text(
          valor.trim().isEmpty ? 'Sin registrar' : valor,
          style: AppTheme.sans(size: 17, weight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget exposicion(Historial registro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.meeting_room_outlined,
                size: 21,
                color: AppTheme.bronze,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FutureBuilder<Sala?>(
                  future: nombres.putIfAbsent(
                    registro.idSala,
                    () => salas.obtenerSalaPorId(registro.idSala),
                  ),
                  builder: (_, dato) => Text(
                    dato.connectionState == ConnectionState.waiting
                        ? 'Cargando sala…'
                        : dato.data?.nombre ?? 'Sala desconocida',
                    style: AppTheme.serif(size: 26, height: 1.15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 36,
            runSpacing: 12,
            children: [
              horario('Inicio', registro.fechaInicio),
              horario('Fin', registro.fechaFin),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    final obra = widget.obra;
    final panel = VidrioPortada(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<List<Historial>>(
          future: registros,
          builder: (_, estado) {
            if (estado.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (estado.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo cargar el historial.'),
                  TextButton(
                    onPressed: () => setState(() {
                      registros = historial.obtenerHistorialPorObra(obra.id);
                    }),
                    child: const Text('Reintentar'),
                  ),
                ],
              );
            }
            final lista = estado.data ?? <Historial>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Exposiciones', style: AppTheme.serif(size: 30)),
                const SizedBox(height: 8),
                if (lista.isEmpty)
                  Text(
                    'Esta obra aún no tiene exposiciones registradas.',
                    style: AppTheme.sans(size: 15, color: AppTheme.muted),
                  ),
                for (final registro in lista) ...[
                  Divider(height: 1, color: AppTheme.line),
                  exposicion(registro),
                ],
              ],
            );
          },
        ),
      ),
    );
    return Scaffold(
      body: MuseoBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VidrioPortada(
                        radio: 30,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const BackButton(),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Historial de exposición',
                                  style: AppTheme.serif(size: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        obra.nombre,
                        style: AppTheme.serif(size: 42, height: 1.1),
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (_, limites) {
                          final compacta = limites.maxWidth < 740;
                          final imagen = VidrioPortada(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: ColoredBox(
                                  color: AppTheme.head,
                                  child: AspectRatio(
                                    aspectRatio: compacta ? 1.65 : 1.3,
                                    child: ImagenObra(
                                      url: obra.imagenUrl,
                                      nombre: obra.nombre,
                                      ajuste: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                          if (compacta) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                imagen,
                                const SizedBox(height: 16),
                                panel,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: imagen),
                              const SizedBox(width: 22),
                              Expanded(flex: 6, child: panel),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
