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
          home: const InicioScreen(),
          builder: (context, child) {
            return ValueListenableBuilder<double>(
              valueListenable: AccesibilidadMuseo.escalaTexto,
              builder: (context, escala, _) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(escala),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      child ?? const SizedBox.shrink(),
                      const Positioned(
                        right: 20,
                        bottom: 20,
                        child: MuseoAccesibilidadWidget(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}