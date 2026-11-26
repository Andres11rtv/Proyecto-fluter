import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AccesibilidadMuseo {
  static final ValueNotifier<double> escalaTexto = ValueNotifier<double>(1.0);
  static final ValueNotifier<String> modoTema = ValueNotifier<String>('light');
  static final ValueNotifier<bool> lecturaAmplia = ValueNotifier<bool>(false);

  static void cambiarEscala(double valor) {
    escalaTexto.value = valor.clamp(0.85, 2.0).toDouble();
  }

  static void cambiarModo(String nuevoModo) {
    AppTheme.aplicarModo(nuevoModo);
    modoTema.value = nuevoModo;
  }

  static void restablecer() {
    escalaTexto.value = 1.0;
    lecturaAmplia.value = false;
    cambiarModo('light');
  }
}

class MuseoAccesibilidadWidget extends StatefulWidget {
  const MuseoAccesibilidadWidget({super.key});

  @override
  State<MuseoAccesibilidadWidget> createState() =>
      _MuseoAccesibilidadWidgetState();
}

class _MuseoAccesibilidadWidgetState extends State<MuseoAccesibilidadWidget> {
  bool _abierto = false;

  Widget _botonModo(String id, String etiqueta, String actual) {
    final activo = actual == id;
    return Expanded(
      child: activo
          ? FilledButton(
              onPressed: () => AccesibilidadMuseo.cambiarModo(id),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
              child: Text(etiqueta, style: const TextStyle(fontSize: 12)),
            )
          : OutlinedButton(
              onPressed: () => AccesibilidadMuseo.cambiarModo(id),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
              child: Text(etiqueta, style: const TextStyle(fontSize: 12)),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_abierto)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 295,
                maxHeight: MediaQuery.sizeOf(context).height * 0.72,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.line, width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.ink.withValues(alpha: 0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Accesibilidad',
                            style: AppTheme.serif(
                              size: 25,
                              weight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cerrar opciones de accesibilidad',
                            onPressed: () => setState(() => _abierto = false),
                            icon: Icon(Icons.close, size: 20, color: AppTheme.ink),
                          ),
                        ],
                      ),
                      Divider(color: AppTheme.line),
                      const SizedBox(height: 8),

                      // Tamaño de texto
                      ValueListenableBuilder<double>(
                        valueListenable: AccesibilidadMuseo.escalaTexto,
                        builder: (context, escala, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tamaño de texto · ${(escala * 100).round()}%',
                              style: AppTheme.sans(
                                size: 12.5,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: escala <= 0.85
                                        ? null
                                        : () => AccesibilidadMuseo.cambiarEscala(
                                            escala - 0.1),
                                    child: const Text('A−'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        AccesibilidadMuseo.cambiarEscala(1.0),
                                    child: const Text('100%'),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: escala >= 1.35
                                        ? null
                                        : () => AccesibilidadMuseo.cambiarEscala(
                                            escala + 0.1),
                                    child: const Text('A+'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Modo de galería (Claro / Oscuro / Contraste)
                      ValueListenableBuilder<String>(
                        valueListenable: AccesibilidadMuseo.modoTema,
                        builder: (context, modo, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo de galería',
                              style: AppTheme.sans(
                                size: 12.5,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _botonModo('light', 'Claro', modo),
                                const SizedBox(width: 6),
                                _botonModo('dark', 'Oscuro', modo),
                                const SizedBox(width: 6),
                                _botonModo('contrast', 'Contraste', modo),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Lectura amplia
                      ValueListenableBuilder<bool>(
                        valueListenable: AccesibilidadMuseo.lecturaAmplia,
                        builder: (context, amplia, _) => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            'Lectura amplia',
                            style: AppTheme.sans(
                              size: 12.5,
                              weight: FontWeight.w600,
                            ),
                          ),
                          value: amplia,
                          activeTrackColor: AppTheme.bronze,
                          onChanged: (v) =>
                              AccesibilidadMuseo.lecturaAmplia.value = v,
                        ),
                      ),
                      const SizedBox(height: 6),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: AccesibilidadMuseo.restablecer,
                          child: const Text('Restablecer todo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_abierto) const SizedBox(height: 12)
          // FloatingActionButton.small(
          //   heroTag: 'accesibilidad_museo',
          //   backgroundColor: AppTheme.btn,
          //   foregroundColor: AppTheme.btnTexto,
          //   tooltip: _abierto ? 'Ocultar accesibilidad' : 'Abrir accesibilidad',
          //   onPressed: () {},
          //   child: const Icon(Icons.accessibility_new_rounded),
          // ),
        ],
      ),
    );
  }
}