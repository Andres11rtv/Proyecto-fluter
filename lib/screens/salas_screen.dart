import 'registro_screen.dart';
import 'package:flutter/material.dart';
import '../models/sala.dart';
import '../services/contract/museo_service.dart';
import '../services/contract/sala_service.dart';
import '../services/museo_service_impl.dart';
import '../services/sala_service_impl.dart';
import '../widgets/admin_widgets.dart';
import 'sala_detalle_screen.dart';

class SalasScreen extends StatelessWidget {
  const SalasScreen({super.key});

  Future<AdminDatos<Sala>> _cargar() async {
    final SalaService salaServicio = SalaServiceImpl();
    final MuseoService museoServicio = MuseoServiceImpl();
    final salas = await salaServicio.obtenerSalas();
    final museos = await museoServicio.obtenerMuseos();

    String nombreMuseo(int id) =>
        museos.where((m) => m.id == id).map((m) => m.nombre).firstOrNull ?? '—';
    final aforo = salas.fold<int>(0, (suma, s) => suma + s.capacidad);

    return AdminDatos<Sala>(
      items: salas,
      idRegistro: (item) => item.id, nombreRegistro: (item) => item.nombre,
      kpis: [
        KpiDato('Salas configuradas', '${salas.length}'),
        KpiDato('Aforo total', '$aforo'),
      ],
      campos: [
        const CampoRegistro('nombre', 'Nombre de la sala', obligatorio: true),
        const CampoRegistro('descripcion', 'Descripción', lineas: 3),
        CampoRegistro('capacidad', 'Capacidad de visitantes', obligatorio: true, validar: (v) {
              final n = int.tryParse(v);
              return n == null || n < 0 ? 'Valor fuera de rango.' : null;
            }),
        CampoRegistro('id_museo', 'Museo', obligatorio: true, opciones: {for (final item in museos) item.id: item.nombre}),
      ],
      guardar: salaServicio.registrar,
      textoBusqueda: (s) => '${s.nombre} ${s.descripcion} ${nombreMuseo(s.idMuseo)}',
      celdas: (s) => [
        AdminCeldas.titulo(s.nombre),
        AdminCeldas.texto(nombreMuseo(s.idMuseo)),
        AdminCeldas.texto('${s.capacidad}'),
      ],
      detalle: (s) => SalaDetalleScreen(sala: s),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminListPage<Sala>(
      activeId: 'salas',
      bannerUrl: 'https://images.unsplash.com/photo-1554907984-15263bfd63bd?auto=format&fit=crop&w=900&q=80',
      titulo: 'Salas de exposición',
      subtitulo: 'Organiza los espacios interiores de cada museo y su capacidad de aforo.',
      textoNuevo: 'Nueva sala',
      hintBusqueda: 'Buscar salas...',
      tituloForm: 'Datos de la sala',
      columnas: const ['Nombre', 'Museo', 'Capacidad'],
      cargar: _cargar,
    );
  }
}
