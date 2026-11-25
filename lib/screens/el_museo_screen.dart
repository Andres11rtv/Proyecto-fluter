import '../rutas_museo.dart';
import 'package:flutter/material.dart';
import '../models/museo.dart';
import '../services/museo_service_impl.dart';
import '../theme/app_theme.dart';
import 'museo_detalle_screen.dart';

class ElMuseoScreen extends StatefulWidget {
  const ElMuseoScreen({super.key});

  @override
  State<ElMuseoScreen> createState() => _ElMuseoScreenState();
}

class _ElMuseoScreenState extends State<ElMuseoScreen> {
  final servicio = MuseoServiceImpl();
  late Future<List<Museo>> registros = servicio.obtenerMuseos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('El museo')),
      body: MuseoBackdrop(
        child: FutureBuilder<List<Museo>>(
          future: registros,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: TextButton(
                onPressed: () => setState(() { registros = servicio.obtenerMuseos(); }),
                child: const Text('No se pudieron cargar los museos. Reintentar'),
              ));
            }
            final items = snapshot.requireData;
            if (items.isEmpty) return const Center(child: Text('Sin museos registrados.'));
            return Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(padding: const EdgeInsets.all(24), children: [
                Text('Sedes del museo', style: AppTheme.serif(size: 38)),
                const SizedBox(height: 18),
                for (final museo in items) Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(clipBehavior: Clip.antiAlias, child: InkWell(
                    onTap: () => Navigator.push(context, rutaMuseo(MuseoDetalleScreen(museo: museo))),
                    child: Padding(padding: const EdgeInsets.all(24), child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.account_balance_outlined, color: AppTheme.bronze),
                        const SizedBox(height: 12),
                        Text(museo.nombre, style: AppTheme.serif(size: 32)),
                        const SizedBox(height: 6),
                        Text(museo.descripcion, style: AppTheme.sans(height: 1.55)),
                        const SizedBox(height: 16),
                        Text('Explorar salas →', style: AppTheme.sans(color: AppTheme.bronze, weight: FontWeight.w600)),
                      ],
                    )),
                  )),
                ),
              ]),
            ));
          },
        ),
      ),
    );
  }
}
