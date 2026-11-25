import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ImagenObra extends StatelessWidget {
  final String url;
  final String nombre;
  final bool miniatura;

  const ImagenObra({super.key, required this.url, required this.nombre, this.miniatura = false});

  Widget reserva() {
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
    if (url.trim().isEmpty) return reserva();
    return Image.network(url.trim(), fit: BoxFit.cover, semanticLabel: nombre,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (_, _, _) => reserva());
  }
}
