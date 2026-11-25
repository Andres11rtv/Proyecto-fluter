import 'registro_screen.dart';
import 'package:flutter/material.dart';
import '../models/museo.dart';
import '../services/contract/museo_service.dart';
import '../services/contract/sala_service.dart';
import '../services/museo_service_impl.dart';
import '../services/sala_service_impl.dart';
import '../widgets/admin_widgets.dart';
import 'museo_detalle_screen.dart';

class MuseosScreen extends StatelessWidget {
  const MuseosScreen({super.key});

  Future<AdminDatos<Museo>> _cargar() async {
    final MuseoService museoServicio = MuseoServiceImpl();
    final SalaService salaServicio = SalaServiceImpl();
    final museos = await museoServicio.obtenerMuseos();
    final salas = await salaServicio.obtenerSalas();

    return AdminDatos<Museo>(
      items: museos,
      kpis: [
        KpiDato('Sedes registradas', '${museos.length}'),
        KpiDato('Salas totales', '${salas.length}'),
      ],
      campos: [
        const CampoRegistro('nombre', 'Nombre del museo', obligatorio: true),
        const CampoRegistro('descripcion', 'Descripción', lineas: 3),
        CampoRegistro('latitud', 'Latitud', obligatorio: true, validar: (v) {
              final n = double.tryParse(v);
              return n == null || !n.isFinite || n < -90 || n > 90 ? 'Valor fuera de rango.' : null;
            }),
        CampoRegistro('longitud', 'Longitud', obligatorio: true, validar: (v) {
              final n = double.tryParse(v);
              return n == null || !n.isFinite || n < -180 || n > 180 ? 'Valor fuera de rango.' : null;
            }),
        const CampoRegistro('url', 'Sitio web'),
      ],
      guardar: museoServicio.registrar,
      textoBusqueda: (m) => '${m.nombre} ${m.descripcion} ${m.sitioWeb}',
      celdas: (m) => [
        AdminCeldas.titulo(m.nombre),
        AdminCeldas.texto('${m.latitud}, ${m.longitud}'),
        AdminCeldas.texto(m.sitioWeb),
      ],
      detalle: (m) => MuseoDetalleScreen(museo: m),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminListPage<Museo>(
      activeId: 'museos',
      titulo: 'Gestión de museos',
      subtitulo: 'Administra las sedes, ubicaciones geográficas y portales web del sistema.',
      textoNuevo: 'Nuevo museo',
      hintBusqueda: 'Buscar museos...',
      tituloForm: 'Datos del museo',
      columnas: const ['Nombre', 'Ubicación', 'Sitio web'],
      cargar: _cargar,
    );
  }
}
