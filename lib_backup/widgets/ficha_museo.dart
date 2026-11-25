import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FichaMuseo extends StatelessWidget {
  final String titulo;
  final Widget body;

  const FichaMuseo({super.key, required this.titulo, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: MuseoBackdrop(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Card(clipBehavior: Clip.antiAlias,
            child: SizedBox.expand(child: body)),
        ),
      ))),
    );
  }
}
