import 'seleccion_destacada.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ImagenObra extends StatelessWidget {
  final String url;
  final String nombre;
  final bool miniatura;
  final BoxFit ajuste;

  const ImagenObra({super.key, required this.url, required this.nombre, this.miniatura = false, this.ajuste = BoxFit.cover});

  static const fotosDeCatalogo = <String, String>{
    'plaza de bolívar, 1950': 'plaza',
    'vasija ritual muisca': 'vasija',
    'las dos fridas': 'fridas',
    'naturaleza muerta con guitarra': 'guitarra',
    'la huida': 'huida',
    'aparato mágico': 'aparato',
    'la violencia': 'violencia',
    'pájaro': 'pajaro',
    'mona lisa a los doce años': 'monalisa',
    'mona lisa a los 12 años': 'monalisa',
    'la mona lisa a los doce años': 'monalisa',
    'la mona lisa a los 12 años': 'monalisa',
  };

  Widget reserva({bool usarFotoLocal = true}) {
    final foto = fotosDeCatalogo[nombre.trim().toLowerCase()];
    if (usarFotoLocal && foto != null) {
      final referencia = const {'plaza', 'vasija', 'huida'}.contains(foto);
      final imagen = Image.asset(
        'assets/destacadas/catalogo_$foto.jpg',
        fit: ajuste,
        semanticLabel: referencia ? 'Imagen de referencia para $nombre' : nombre,
        errorBuilder: (_, _, _) => reserva(usarFotoLocal: false),
      );
      if (!referencia || miniatura) {
        return imagen;
      }
      return Stack(
        fit: StackFit.passthrough,
        children: [
          imagen,
          Positioned(
            right: 6, bottom: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(color: const Color(0xCC23201D), borderRadius: BorderRadius.circular(8)),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                child: Text('Imagen de referencia', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
          ),
        ],
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [AppTheme.head, AppTheme.surface, AppTheme.bronzeLight],
      )),
      child: Center(child: Tooltip(message: 'Imagen no disponible: $nombre',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.photo_library_outlined, size: miniatura ? 20 : 34, color: AppTheme.bronze),
          if (!miniatura) ...[
            const SizedBox(height: 8),
            Text(url.trim().isEmpty ? 'Sin imagen registrada' : 'Imagen no disponible',
              style: AppTheme.sans(size: 12, color: AppTheme.muted)),
          ],
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = fotosDestacadas[nombre.trim().toLowerCase()];
    Widget alternativa() {
      if (local == null) return reserva();
      return Image.asset(local, fit: ajuste, semanticLabel: nombre,
        errorBuilder: (_, _, _) => reserva());
    }

    final direccion = url.trim();
    final uri = Uri.tryParse(direccion);
    if (uri == null || direccion.isEmpty) return alternativa();
    if (uri.host == 'example.com' || uri.host.endsWith('.example.com')) return alternativa();
    return Image.network(direccion, fit: ajuste, semanticLabel: nombre,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (_, _, _) => alternativa());
  }
}
