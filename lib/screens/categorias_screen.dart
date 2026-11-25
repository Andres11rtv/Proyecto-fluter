import 'registro_screen.dart';
import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/contract/categoria_service.dart';
import '../services/categoria_service_impl.dart';
import '../widgets/admin_widgets.dart';
import 'categoria_detalle_screen.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  Future<AdminDatos<Categoria>> _cargar() async {
    final CategoriaService servicio = CategoriaServiceImpl();
    final categorias = await servicio.obtenerCategorias();

    return AdminDatos<Categoria>(
      items: categorias,
      idRegistro: (item) => item.id, nombreRegistro: (item) => item.nombre,
      campos: [
        const CampoRegistro('nombre', 'Nombre de la categoría', obligatorio: true),
        const CampoRegistro('descripcion', 'Descripción', lineas: 3),
      ],
      guardar: servicio.registrar,
      textoBusqueda: (c) => '${c.nombre} ${c.descripcion}',
      celdas: (c) => [
        AdminCeldas.titulo(c.nombre),
        AdminCeldas.texto(c.descripcion),
      ],
      detalle: (c) => CategoriaDetalleScreen(categoria: c),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminListPage<Categoria>(
      activeId: 'categorias',
      titulo: 'Categorías de obras',
      subtitulo: 'Clasifica las piezas por técnica, época o colección para facilitar su búsqueda.',
      textoNuevo: 'Nueva categoría',
      tituloForm: 'Datos de la categoría',
      tituloListado: 'Listado de categorías',
      columnas: const ['Nombre', 'Descripción'],
      conBuscador: false,
      cargar: _cargar,
    );
  }
}
