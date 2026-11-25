import '../widgets/vidrio_portada.dart';
import 'historial_general_screen.dart';
import '../widgets/sobre_portada.dart';
import '../widgets/galeria_portada.dart';
import '../services/obra_service_impl.dart';
import '../widgets/portada_coleccion.dart';
import 'coleccion_screen.dart';
import 'el_museo_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'artistas_screen.dart';
import 'categorias_screen.dart';
import 'museos_screen.dart';
import 'obras_screen.dart';
import 'recorridos_screen.dart';
import 'salas_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final servicio = ObraServiceImpl();
  late var obras = servicio.obtenerObras();
  int version = 0;

  Future<void> _irA(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) setState(() { version++; obras = servicio.obtenerObras(); });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _esContraste => AppTheme.modo == 'contrast';

  Color _vidrio([double alphaClaro = 0.74]) {
    if (_esContraste) return AppTheme.surface;
    return AppTheme.surface.withValues(alpha: alphaClaro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MuseoBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 20),
                        _buildTicker(),
                        const SizedBox(height: 32),
                        const SobrePortada(),
                        const SizedBox(height: 32),
                        GaleriaPortada(key: ValueKey(version), obras: obras, abrir: _irA),
                        const SizedBox(height: 36),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 20,
                right: 20,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: _buildTopNavbar(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavbar() {
    if (MediaQuery.sizeOf(context).width < 760) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _esContraste ? 0 : 24,
            sigmaY: _esContraste ? 0 : 24,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 8, 10, 8),
            decoration: BoxDecoration(
              color: _vidrio(0.78),
              border: Border.all(
                color: _esContraste
                    ? AppTheme.line
                    : AppTheme.surface.withValues(alpha: 0.8),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: Text(
                    'MUSEO',
                    style: AppTheme.serif(
                      size: 19,
                      weight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  tooltip: 'Secciones de inicio',
                  icon: Icon(Icons.menu_rounded, color: AppTheme.ink),
                  onSelected: (id) {
                    switch (id) {
                      case 'inicio':
                        return;
                      case 'sobre':
                        _irA(const ElMuseoScreen());
                      case 'coleccion':
                        _irA(const ColeccionScreen());
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'inicio', child: Text('Inicio')),
                    PopupMenuItem(value: 'sobre', child: Text('El Museo')),
                    PopupMenuItem(value: 'coleccion', child: Text('Colección')),
                  ],
                ),
                _buildAdminMenuButton(),
              ],
            ),
          ),
        ),
      );
    }

    return VidrioPortada(
      radio: 999,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'MUSEO',
                    style: AppTheme.serif(
                      size: 20,
                      weight: FontWeight.w700,
                      letterSpacing: 5.5,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.head.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _navPill(
                      'inicio',
                      'Inicio',
                      () {},
                    ),
                    _navPill(
                      'sobre',
                      'El Museo',
                      () => _irA(const ElMuseoScreen()),
                    ),
                    _navPill(
                      'coleccion',
                      'Colección',
                      () => _irA(const ColeccionScreen()),
                    ),
                  ],
                ),
              ),
              _buildAdminMenuButton(),
            ],
          ),
      ),
    );
  }

  Widget _navPill(String id, String label, VoidCallback onTap) {
    return _HoverNavPill(
      label: label,
      active: id == 'inicio',
      onTap: onTap,
    );
  }

  Widget _buildAdminMenuButton() {
    return PopupMenuButton<Widget>(
      onSelected: _irA,
      offset: const Offset(0, 48),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.line),
      ),
      itemBuilder: (context) => [
        _menuItem(
          const MuseosScreen(),
          Icons.account_balance_outlined,
          'Museos',
          'Sedes y ubicaciones',
        ),
        _menuItem(
          const SalasScreen(),
          Icons.meeting_room_outlined,
          'Salas',
          'Espacios de exposición',
        ),
        _menuItem(
          const ArtistasScreen(),
          Icons.person_outline,
          'Artistas',
          'Autores y biografías',
        ),
        _menuItem(
          const CategoriasScreen(),
          Icons.category_outlined,
          'Categorías',
          'Clasificación de piezas',
        ),
        _menuItem(
          const ObrasScreen(),
          Icons.photo_library_outlined,
          'Obras',
          'Inventario y estado',
        ),
        _menuItem(const HistorialGeneralScreen(), Icons.history, 'Historial', 'Exposiciones de obras'),
        _menuItem(
          const RecorridosScreen(),
          Icons.route_outlined,
          'Recorridos',
          'Visitas guiadas',
        ),
      ],
      child: MediaQuery.sizeOf(context).width < 760
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: AppTheme.ink,
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: _vidrio(0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.line, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Administración',
                    style: AppTheme.sans(size: 13.5, weight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 17,
                    color: AppTheme.bronze,
                  ),
                ],
              ),
            ),
    );
  }

  PopupMenuItem<Widget> _menuItem(
    Widget screen,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return PopupMenuItem<Widget>(
      value: screen,
      height: 54,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.head,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.bronze),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTheme.sans(size: 13.5, weight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: AppTheme.sans(size: 11.5, color: AppTheme.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _heroGradientColors() {
    if (AppTheme.modo == 'dark') {
      const base = Color(0xFF0B0E14);
      return [
        base.withValues(alpha: 0.96),
        base.withValues(alpha: 0.86),
        base.withValues(alpha: 0.38),
        base.withValues(alpha: 0.12),
      ];
    }
    if (_esContraste) {
      return [
        Colors.black.withValues(alpha: 0.99),
        Colors.black.withValues(alpha: 0.96),
        Colors.black.withValues(alpha: 0.85),
        Colors.black.withValues(alpha: 0.72),
      ];
    }
    const base = Color(0xFFFCF9F4);
    return [
      base.withValues(alpha: 0.96),
      base.withValues(alpha: 0.85),
      base.withValues(alpha: 0.28),
      base.withValues(alpha: 0.04),
    ];
  }

  Widget _buildHero() {
    final compacto = MediaQuery.sizeOf(context).width < 700;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.line, width: 1.5),
          boxShadow: _esContraste
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.ink.withValues(alpha: 0.08),
                    blurRadius: 34,
                    offset: const Offset(0, 14),
                  ),
                ],
        ),
        child: Stack(
          children: [
            if (!_esContraste)
              Positioned.fill(child: Image.network(
                'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=1200&q=80', fit: BoxFit.cover, alignment: Alignment.centerRight,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => ColoredBox(color: AppTheme.head),
              )),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.44, 0.76, 1.0],
                    colors: compacto ? [for (final color in _heroGradientColors()) color.withValues(alpha: 0.92)] : _heroGradientColors(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compacto ? 18 : 45,
                compacto ? 26 : 44,
                compacto ? 18 : 45,
                compacto ? 22 : 44,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _vidrio(0.84),
                      border: Border.all(color: AppTheme.bronze, width: 1.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: AppTheme.bronze,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TEMPORADA CULTURAL ${DateTime.now().year}',
                          style: AppTheme.sans(
                            size: compacto ? 9 : 10.5,
                            weight: FontWeight.w700,
                            letterSpacing: compacto ? 1.1 : 2,
                            color: AppTheme.bronze,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.serif(
                          size: compacto ? 39 : 58,
                          height: 1.03,
                          weight: FontWeight.w600,
                          letterSpacing: -0.6,
                        ),
                        children: [
                          const TextSpan(text: 'Espacios que\n'),
                          TextSpan(
                            text: 'inspiran ',
                            style: AppTheme.serif(
                              size: compacto ? 39 : 58,
                              height: 1.03,
                              weight: FontWeight.w600,
                              style: FontStyle.italic,
                              color: AppTheme.bronze,
                            ),
                          ),
                          const TextSpan(text: 'historia'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Text(
                      'Un viaje arquitectónico y curatorial por nuestras colecciones, salas de exhibición y patrimonio histórico en un solo lugar.',
                      style: AppTheme.sans(
                        size: 16,
                        height: 1.6,
                        color: AppTheme.inkSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 4, 6, 4),
                      decoration: BoxDecoration(
                        color: _vidrio(0.82),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.line, width: 1.5),
                        boxShadow: _esContraste
                            ? null
                            : [
                                BoxShadow(
                                  color: AppTheme.ink.withValues(alpha: 0.05),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppTheme.bronze, size: 19),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: AppTheme.sans(size: 14),
                              decoration: const InputDecoration(
                                hintText: 'Buscar obra, artista o año...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (texto) =>
                                  _irA(ColeccionScreen(busquedaInicial: texto)),
                            ),
                          ),
                          FilledButton(
                            onPressed: () => _irA(
                              ColeccionScreen(busquedaInicial: _searchCtrl.text),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('Buscar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: compacto ? 26 : 44),
                  PortadaColeccion(key: ValueKey(version), obras: obras),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicker() {
    const mensajes = [
      'COLECCIÓN', 'ARTISTAS', 'SALAS DE EXPOSICIÓN', 'PATRIMONIO', 'VISITAS CURATORIALES',
    ];
    return VidrioPortada(
      radio: 999,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: LayoutBuilder(builder: (context, box) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: box.maxWidth),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                for (final mensaje in mensajes) ...[
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(mensaje, style: AppTheme.sans(size: 12, weight: FontWeight.w700, letterSpacing: 1.4))),
                  Icon(Icons.auto_awesome, size: 12, color: AppTheme.bronze),
                ],
              ]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.line)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 20,
        runSpacing: 8,
        children: [
          Text(
            'MUSEO',
            style: AppTheme.serif(
              size: 16,
              weight: FontWeight.w700,
              letterSpacing: 4.5,
            ),
          ),
          TextButton(onPressed: () => _irA(const ElMuseoScreen()), child: const Text('El Museo')),
          TextButton(onPressed: () => _irA(const ColeccionScreen()), child: const Text('Colección')),
          Text(
            'Sistema de Gestión de Museos · Proyecto Universitario',
            style: AppTheme.sans(size: 12.5, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _HoverNavPill extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _HoverNavPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_HoverNavPill> createState() => _HoverNavPillState();
}

class _HoverNavPillState extends State<_HoverNavPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
          decoration: BoxDecoration(
            color: widget.active
                ? AppTheme.btn
                : (_hovered ? AppTheme.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(999),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: AppTheme.ink.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: AppTheme.sans(
              size: 13.5,
              weight: widget.active ? FontWeight.w600 : FontWeight.w500,
              color: widget.active
                  ? AppTheme.btnTexto
                  : (_hovered ? AppTheme.ink : AppTheme.muted),
            ),
          ),
        ),
      ),
    );
  }
}
