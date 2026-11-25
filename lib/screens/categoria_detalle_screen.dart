import '../rutas_museo.dart';
import '../widgets/ficha_museo.dart';
import '../widgets/imagen_obra.dart';
import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/obra.dart';
import '../services/contract/obra_service.dart';
import '../services/obra_service_impl.dart';
import 'obra_detalle_screen.dart';

class CategoriaDetalleScreen extends StatelessWidget {
  final Categoria categoria;

  const CategoriaDetalleScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final ObraService obraServicio = ObraServiceImpl();

    return FichaMuseo(
      titulo: categoria.nombre, seccion: 'Categorías', icono: Icons.category_outlined,
      body: ListView(shrinkWrap: true, primary: false, physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(categoria.descripcion),
          const SizedBox(height: 24),
          Text(
            'Obras de esta categoría',
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
                  .where((o) => o.idCategoria == categoria.id)
                  .toList();
              if (obras.isEmpty) {
                return const Text('Sin obras');
              }
              return Column(
                children: [
                  for (final obra in obras)
                    ListTile(
                      leading: ClipRRect(borderRadius: BorderRadius.circular(9),
                        child: SizedBox(width: 44, height: 50, child: ImagenObra(
                          url: obra.imagenUrl, nombre: obra.nombre, miniatura: true))),
                      title: Text(obra.nombre),
                      subtitle: Text(obra.descripcion),
                      trailing: Tooltip(message: 'Estado de conservación', child: Text('${obra.porcentajeConservacion}%')),
                      onTap: () {
                        Navigator.push(
                          context,
                          rutaMuseo(ObraDetalleScreen(obra: obra)),
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
