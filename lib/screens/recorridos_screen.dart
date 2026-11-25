import 'registro_screen.dart';
import 'package:flutter/material.dart';
import '../models/recorrido.dart';
import '../services/contract/recorrido_service.dart';
import '../services/contract/sala_service.dart';
import '../services/recorrido_service_impl.dart';
import '../services/sala_service_impl.dart';
import '../widgets/admin_widgets.dart';
import 'recorrido_detalle_screen.dart';

String? validarHora(String valor) {
  final formato = RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$');
  return formato.hasMatch(valor) ? null : 'Escribe una hora válida, por ejemplo 09:30.';
}

class RecorridosScreen extends StatelessWidget {
  const RecorridosScreen({super.key});

  Future<AdminDatos<Recorrido>> _cargar() async {
    final RecorridoService recorridoServicio = RecorridoServiceImpl();
    final SalaService salaServicio = SalaServiceImpl();
    final recorridos = await recorridoServicio.obtenerRecorridos();
    final salas = await salaServicio.obtenerSalas();

    return AdminDatos<Recorrido>(
      items: recorridos,
      idRegistro: (item) => item.id, nombreRegistro: (item) => item.nombre,
      campos: [
        const CampoRegistro('nombre', 'Nombre del recorrido', obligatorio: true),
        const CampoRegistro('descripcion', 'Descripción', lineas: 3),
        const CampoRegistro('comienza', 'Inicio (HH:MM)', obligatorio: true, validar: validarHora),
        const CampoRegistro('finaliza', 'Fin (HH:MM)', obligatorio: true, validar: validarHora),
        const CampoRegistro('url', 'Sitio web'),
        CampoRegistro('sala_inicial', 'Sala inicial', opciones: {for (final item in salas) item.id: item.nombre}),
      ],
      guardar: recorridoServicio.registrar,
      textoBusqueda: (r) => '${r.nombre} ${r.descripcion}',
      celdas: (r) => [
        AdminCeldas.titulo(r.nombre),
        AdminCeldas.texto(r.comienza),
        AdminCeldas.texto(r.finaliza),
      ],
      detalle: (r) => RecorridoDetalleScreen(recorrido: r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminListPage<Recorrido>(
      activeId: 'recorridos',
      titulo: 'Recorridos y visitas guiadas',
      subtitulo: 'Diseña itinerarios temáticos ordenando las salas que visitará el público.',
      textoNuevo: 'Nueva visita guiada',
      tituloForm: 'Itinerario del recorrido',
      columnas: const ['Nombre del recorrido', 'Inicio', 'Fin'],
      conBuscador: false,
      cargar: _cargar,
    );
  }
}
