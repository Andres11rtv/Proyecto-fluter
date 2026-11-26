import 'widgets/capa_accesible.dart';
import 'rutas_museo.dart';
import 'package:flutter/material.dart';
import 'screens/inicio_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/accesibilidad_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AccesibilidadMuseo.modoTema,
      builder: (context, _, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sistema de Gestión de Museos',
          theme: AppTheme.tema,
          home: const InicioScreen(), onGenerateRoute: restaurarRutaMuseo,
          builder: (context, child) => CapaAccesible(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}