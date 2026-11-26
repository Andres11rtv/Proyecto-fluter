import '../rutas_museo.dart';
import 'movimiento_portada.dart';
import 'tarjeta_interactiva.dart';
import 'vidrio_portada.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/coleccion_screen.dart';
import '../screens/el_museo_screen.dart';
import '../screens/recorridos_screen.dart';

class SobrePortada extends StatelessWidget {
  const SobrePortada({super.key});

  static const _imgAbout = 'https://images.unsplash.com/photo-1554907984-15263bfd63bd?auto=format&fit=crop&w=900&q=80';
  bool get _esContraste => AppTheme.modo == 'contrast';
  Color _vidrio(double alpha) => AppTheme.surface.withValues(alpha: _esContraste ? 1 : alpha);

  Widget _chipMuseo(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _vidrio(0.8),
        border: Border.all(color: AppTheme.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: AppTheme.bronze),
          const SizedBox(width: 8),
          Text(
            texto,
            style: AppTheme.sans(
              size: 11,
              weight: FontWeight.w700,
              color: AppTheme.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pilar(
    IconData icono,
    String numero,
    String titulo,
    String descripcion,
    String etiqueta,
    VoidCallback abrir,
  ) {
    return Expanded(
      child: TarjetaInteractiva(child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _vidrio(0.86),
          border: Border.all(color: AppTheme.line),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: AppTheme.bronzeLight,
                  border: Border.all(color: AppTheme.bronze)),
                  child: Icon(icono, color: AppTheme.bronze, size: 24)),
                Text(
                  numero,
                  style: AppTheme.serif(
                    size: 58,
                    weight: FontWeight.w700,
                    color: AppTheme.bronze.withValues(alpha: _esContraste ? 1 : 0.20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(titulo, style: AppTheme.serif(size: 20, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: AppTheme.sans(
                size: 15,
                height: 1.6,
                color: AppTheme.muted,
              ),
            ),
            Divider(height: 30, color: AppTheme.line),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(etiqueta.toUpperCase(), style: AppTheme.sans(
                    size: 10, weight: FontWeight.w700,
                    letterSpacing: 1, color: AppTheme.bronze)),
                  TextButton(
                    onPressed: abrir,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.bronze,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text('Ver más', semanticsLabel: 'Ver más sobre $titulo',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      )),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    return VidrioPortada(
      radio: 32,
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.sizeOf(context).width >= 760 ? 42 : 20),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final ancho = constraints.maxWidth > 680;
                  final texto = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ARQUITECTURA & LEGADO',
                        style: AppTheme.sans(
                          size: 16,
                          color: AppTheme.ink,
                          weight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EntradaTexto(child: Text(
                        'Sobre el museo',
                        style: AppTheme.serif(
                          size: 39,
                          weight: FontWeight.w700,
                        ),
                      )),
                      const SizedBox(height: 10),
                      Text(
                        'Somos una institución dedicada a la conservación, investigación y difusión del patrimonio cultural. Conectamos la memoria histórica con una museografía contemporánea y accesible para todos.',
                        style: AppTheme.sans(
                          size: 16,
                          height: 1.7,
                          color: AppTheme.inkSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '“',
                            style: AppTheme.serif(
                              size: 70,
                              weight: FontWeight.w700,
                              height: 0.8,
                              color: AppTheme.bronze,
                            ),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Text(
                              'Preservar la memoria artística es abrir un diálogo vivo entre las generaciones pasadas y quienes hoy contemplan cada sala.',
                              style: AppTheme.serif(
                                size: 23,
                                style: FontStyle.italic,
                                weight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: const EdgeInsets.fromLTRB(56, 16, 0, 20),
                        child: Container(width: 52, height: 2, color: AppTheme.bronze)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chipMuseo('Mar – Dom · 9:00 a 18:00'),
                          _chipMuseo('Entrada libre domingos'),
                          _chipMuseo('Accesibilidad universal'),
                        ],
                      ),
                    ],
                  );
                  final imagen = _FotoSala(builder: (escala) => ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: SizedBox(
                      height: ancho ? 448 : 330,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedScale(scale: escala, duration: const Duration(milliseconds: 480), curve: Curves.easeOutCubic, child: Image.network(
                            _imgAbout,
                            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                            fit: BoxFit.cover,
                            semanticLabel: 'Galería de pinturas de un museo',
                            errorBuilder: (_, _, _) => Container(
                              color: AppTheme.head,
                              child: Icon(
                                Icons.account_balance_outlined,
                                size: 70,
                                color: AppTheme.bronze,
                              ),
                            ),
                          )),
                          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                            begin: Alignment.bottomCenter, end: Alignment.topCenter,
                            colors: [Colors.black.withValues(alpha: 0.94), Colors.transparent],
                            stops: const [0, 0.72],
                          ))),
                          Positioned(top: 20, left: 22, child: DecoratedBox(
                            decoration: BoxDecoration(color: const Color(0xDF17151B), borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white54)),
                            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text('GALERÍA', style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: Colors.white))))),
                          Positioned(left: 22, right: 22, bottom: 20, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(width: 38, height: 3, color: const Color(0xfff7b383)),
                              const SizedBox(height: 8),
                              Text('Espacios de exposición', style: AppTheme.serif(size: 24, color: Colors.white)),
                              Text('Arquitectura y patrimonio', style: AppTheme.sans(color: Colors.white)),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ));
                  if (ancho) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 117, child: texto),
                        const SizedBox(width: 52),
                        Expanded(flex: 100, child: imagen),
                      ],
                    );
                  }
                  return Column(
                    children: [texto, const SizedBox(height: 20), imagen],
                  );
                },
              ),
              const SizedBox(height: 22),
              Divider(color: AppTheme.line, height: 28),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final items = [
                    _pilar(
                      Icons.palette_outlined,
                      '01',
                      'Obras y artistas',
                      'Explora las obras del catálogo y consulta su autor, categoría y estado de conservación.',
                      'Catálogo de obras',
                      () => Navigator.push(context, rutaMuseo(const ColeccionScreen())),
                    ),
                    _pilar(
                      Icons.account_balance_outlined,
                      '02',
                      'Museos y salas',
                      'Conoce las sedes del museo, las salas de cada sede y cuántas personas caben en cada sala.',
                      'Espacios de exhibición',
                      () => Navigator.push(context, rutaMuseo(const ElMuseoScreen())),
                    ),
                    _pilar(
                      Icons.route_outlined,
                      '03',
                      'Recorridos y horarios',
                      'Consulta las visitas guiadas, su hora de inicio y de fin, y el orden en que se visitan las salas.',
                      'Visitas guiadas',
                      () => Navigator.push(context, rutaMuseo(const RecorridosScreen())),
                    ),
                  ];
                  if (constraints.maxWidth > 760) {
                    return IntrinsicHeight(child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        items[0],
                        const SizedBox(width: 12),
                        items[1],
                        const SizedBox(width: 12),
                        items[2],
                      ],
                    ));
                  }
                  return Column(
                    children: [
                      Row(children: [items[0]]),
                      const SizedBox(height: 12),
                      Row(children: [items[1]]),
                      const SizedBox(height: 12),
                      Row(children: [items[2]]),
                    ],
                  );
                },
              ),
            ],
          ),
      ),
    );
  }

}

class _FotoSala extends StatefulWidget {
  final Widget Function(double escala) builder;
  const _FotoSala({required this.builder});
  @override
  State<_FotoSala> createState() => _FotoSalaState();
}

class _FotoSalaState extends State<_FotoSala> {
  bool encima = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => encima = true),
    onExit: (_) => setState(() => encima = false),
    child: widget.builder(encima && !MediaQuery.disableAnimationsOf(context) ? 1.05 : 1),
  );
}
