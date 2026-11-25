import '../rutas_museo.dart';
import 'package:flutter/material.dart';
import '../services/obra_service_impl.dart';
import '../theme/app_theme.dart';
import '../widgets/galeria_portada.dart';

class ColeccionScreen extends StatefulWidget {
  final String busquedaInicial;
  const ColeccionScreen({super.key, this.busquedaInicial = ''});

  @override
  State<ColeccionScreen> createState() => _ColeccionScreenState();
}

class _ColeccionScreenState extends State<ColeccionScreen> {
  final servicio = ObraServiceImpl();
  late var obras = servicio.obtenerObras();
  late final buscador = TextEditingController(text: widget.busquedaInicial);
  int version = 0;

  @override
  void dispose() {
    buscador.dispose();
    super.dispose();
  }

  Future<void> abrir(Widget pantalla) async {
    await Navigator.push(context, rutaMuseo(pantalla));
    if (mounted) setState(() { version++; obras = servicio.obtenerObras(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Colección')),
      body: MuseoBackdrop(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1140),
        child: ListView(padding: const EdgeInsets.all(24), children: [
          TextField(controller: buscador, onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
              labelText: 'Buscar obra, artista, categoría o año')),
          const SizedBox(height: 20),
          GaleriaPortada(key: ValueKey(version), obras: obras, abrir: abrir,
            completa: true, busqueda: buscador.text),
        ]),
      ))));
  }
}
