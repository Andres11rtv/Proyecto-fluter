import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _vidrio(0.65),
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
            Text(
              titulo,
              style: AppTheme.serif(size: 23, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: AppTheme.sans(
                size: 12.5,
                height: 1.6,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              etiqueta.toUpperCase(),
              style: AppTheme.sans(
                size: 10,
                weight: FontWeight.w700,
                letterSpacing: 1,
                color: AppTheme.bronze,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _esContraste ? 0 : 24,
          sigmaY: _esContraste ? 0 : 24,
        ),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _vidrio(0.72),
            border: Border.all(
              color: _esContraste
                  ? AppTheme.line
                  : AppTheme.surface.withValues(alpha: 0.85),
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _esContraste
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.ink.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
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
                          size: 10,
                          color: AppTheme.bronze,
                          weight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sobre el museo',
                        style: AppTheme.serif(
                          size: 39,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Somos una institución dedicada a la conservación, investigación y difusión del patrimonio cultural. Conectamos la memoria histórica con una museografía contemporánea y accesible para todos.',
                        style: AppTheme.sans(
                          size: 13.5,
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Preservar la memoria artística es abrir un diálogo vivo entre las generaciones pasadas y quienes hoy contemplan cada sala.',
                              style: AppTheme.serif(
                                size: 23,
                                style: FontStyle.italic,
                                weight: FontWeight.w600,
                                height: 1.32,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chipMuseo('Obras'),
                          _chipMuseo('Salas'),
                          _chipMuseo('Recorridos'),
                        ],
                      ),
                    ],
                  );
                  final imagen = ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: SizedBox(
                      height: 360,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
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
                          ),
                          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                            begin: Alignment.bottomCenter, end: Alignment.topCenter,
                            colors: [Colors.black.withValues(alpha: 0.94), Colors.transparent],
                            stops: const [0, 0.72],
                          ))),
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
                  );
                  if (ancho) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 11, child: texto),
                        const SizedBox(width: 30),
                        Expanded(flex: 10, child: imagen),
                      ],
                    );
                  }
                  return Column(
                    children: [texto, const SizedBox(height: 20), imagen],
                  );
                },
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final items = [
                    _pilar(
                      Icons.shield_outlined,
                      '01',
                      'Conservación Preventiva',
                      'Consulta el porcentaje de conservación registrado en la ficha de cada obra.',
                      'Estado de las obras',
                    ),
                    _pilar(
                      Icons.visibility_outlined,
                      '02',
                      'Curaduría Accesible',
                      'Explora las fichas con las opciones de tamaño de texto y contraste.',
                      'Diseño Inclusivo',
                    ),
                    _pilar(
                      Icons.menu_book_outlined,
                      '03',
                      'Archivo Vivo',
                      'Trazabilidad histórica completa de exposiciones, autores y movimientos entre nuestras sedes.',
                      'Documentación Digital',
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
      ),
    );
  }

}
