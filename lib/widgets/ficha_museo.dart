import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'vidrio_portada.dart';

class FichaMuseo extends StatelessWidget {
  final String titulo;
  final Widget body;
  final String seccion;
  final IconData icono;

  const FichaMuseo({super.key, required this.titulo, required this.body,
    this.seccion = 'Colección', this.icono = Icons.account_balance_outlined});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MuseoBackdrop(child: SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: VidrioPortada(radio: 28, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(children: [
              const BackButton(),
              const SizedBox(width: 8),
              Expanded(child: Text(seccion, style: AppTheme.sans(
                size: 15, weight: FontWeight.w600))),
              Padding(padding: const EdgeInsets.only(right: 12),
                child: Icon(icono, color: AppTheme.bronze, size: 21)),
            ]),
          )),
        ),
      ),
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 40),
        children: [Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(titulo, style: AppTheme.serif(size: 38, height: 1.15)),
            const SizedBox(height: 18),
            VidrioPortada(child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListTileTheme(
                data: ListTileThemeData(
                  iconColor: AppTheme.bronze,
                  titleTextStyle: AppTheme.sans(size: 16, weight: FontWeight.w600),
                  subtitleTextStyle: AppTheme.sans(size: 14, height: 1.45, color: AppTheme.muted),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: DefaultTextStyle(style: AppTheme.sans(size: 16, height: 1.55), child: body),
              ),
            )),
          ]),
        ))],
      )),
    ]))));
  }
}