import '../widgets/selector_museo.dart';
import 'package:flutter/material.dart';
import '../services/eliminacion_service.dart';
import '../widgets/papelera_registro.dart';
import '../models/historial.dart';
import '../services/historial_service_impl.dart';
import '../services/obra_service_impl.dart';
import '../services/sala_service_impl.dart';
import '../widgets/admin_widgets.dart';

class HistorialGeneralScreen extends StatefulWidget {
  const HistorialGeneralScreen({super.key});
  @override
  State<HistorialGeneralScreen> createState() => _HistorialGeneralScreenState();
}

class _HistorialGeneralScreenState extends State<HistorialGeneralScreen> {
  final obras = <int, String>{};
  final salas = <int, String>{};
  int? obraElegida;
  int? salaElegida;
  late Future<List<Historial>> registros = cargar();

  Future<List<Historial>> cargar() async {
    final lista = await HistorialServiceImpl().obtenerHistorial();
    if (lista.isNotEmpty) {
      for (final o in await ObraServiceImpl().obtenerObras()) { obras[o.id] = o.nombre; }
      for (final s in await SalaServiceImpl().obtenerSalas()) { salas[s.id] = s.nombre; }
    }
    return lista;
  }

  Widget filtro(String titulo, Map<int, String> items, int? id, ValueChanged<int?> cambio) {
    return SizedBox(width: 240, child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(titulo, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Semantics(label: titulo, child: selectorMuseo<int>(
      initialValue: id, isExpanded: true, decoration: const InputDecoration(),
      items: [const DropdownMenuItem<int>(child: Text('Todas')),
        for (final e in items.entries) DropdownMenuItem(value: e.key,
          child: Text(e.value, overflow: TextOverflow.ellipsis))],
      onChanged: cambio,
        )),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(activeId: 'historial', children: [
      const AdminHead(extra: AdminBanner(url: 'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=600&q=80'), titulo: 'Historial de exposición', subtitulo: 'Consulta las horas de exposición de cada obra y su sala.'),
      const SizedBox(height: 18),
      FutureBuilder<List<Historial>>(future: registros, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Text('No se pudo consultar el historial.');
        final lista = snapshot.requireData;
        if (lista.isEmpty) return const Text('Sin exposiciones registradas.');
        final visibles = lista.where((r) => (obraElegida == null || r.idObra == obraElegida)
            && (salaElegida == null || r.idSala == salaElegida));
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AdminPanel(child: Wrap(spacing: 16, runSpacing: 12, children: [
            filtro('Obra', obras, obraElegida, (v) => setState(() => obraElegida = v)),
            filtro('Sala', salas, salaElegida, (v) => setState(() => salaElegida = v)),
          ])),
          const SizedBox(height: 18),
          if (visibles.isEmpty) const Text('Sin exposiciones para estos filtros.') else AdminTabla(columnas: const ['Obra', 'Sala', 'Comienza', 'Termina', 'Acciones'], filas: [
          for (final item in visibles) DataRow(cells: [
            DataCell(Text(obras[item.idObra] ?? '—')),
            DataCell(Text(salas[item.idSala] ?? '—')),
            DataCell(Text(item.fechaInicio)), DataCell(Text(item.fechaFin)),
            DataCell(PapeleraRegistro(tipo: RegistroMuseo.historial, id: item.id,
              nombre: '${obras[item.idObra] ?? "Obra ${item.idObra}"} · ${salas[item.idSala] ?? "Sala ${item.idSala}"} · ${item.fechaInicio} – ${item.fechaFin} (#${item.id})',
              alEliminar: () { if (mounted) setState(() { registros = cargar(); }); })),

          ]),
        ]),
        ]);
      }),
    ]);
  }
}
