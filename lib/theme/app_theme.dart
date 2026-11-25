import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta activa: cambia según el modo de galería
  static _Paleta _p = _Paleta.clara;
  static String modo = 'light';

  static void aplicarModo(String nuevo) {
    modo = nuevo;
    _p = nuevo == 'dark'
        ? _Paleta.oscura
        : nuevo == 'contrast'
            ? _Paleta.contraste
            : _Paleta.clara;
  }

  static Brightness get brillo =>
      modo == 'light' ? Brightness.light : Brightness.dark;

  static Color get bg => _p.bg;
  static Color get surface => _p.surface;
  static Color get ink => _p.ink;
  static Color get inkSecondary => _p.inkSecondary;
  static Color get muted => _p.muted;
  static Color get mutedLight => _p.mutedLight;
  static Color get bronze => _p.bronze;
  static Color get bronzeDark => _p.bronzeDark;
  static Color get bronzeLight => _p.bronzeLight;
  static Color get bronzeBorder => _p.bronzeBorder;
  static Color get line => _p.line;
  static Color get head => _p.head;
  static Color get btn => _p.btn;
  static Color get btnTexto => _p.btnTexto;

  static TextStyle serif({
    double size = 24,
    FontWeight weight = FontWeight.w600,
    FontStyle style = FontStyle.normal,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      color: color ?? ink,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? ink,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get tema => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: ink,
      displayColor: ink,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: bronze,
      brightness: brillo,
      primary: btn,
      secondary: bronze,
      surface: surface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: serif(size: 20, weight: FontWeight.w700, letterSpacing: 4),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: modo == 'contrast' ? 0 : 2,
      shadowColor: ink.withValues(alpha: 0.14),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return btn.withValues(alpha: 0.85);
          }
          return btn;
        }),
        foregroundColor: WidgetStatePropertyAll(btnTexto),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        textStyle: WidgetStatePropertyAll(
          sans(size: 13.5, weight: FontWeight.w600, color: btnTexto),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return bronze;
          return ink;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return surface;
          return Colors.transparent;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return BorderSide(color: bronze, width: 1.5);
          }
          return BorderSide(color: line, width: 1.5);
        }),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        textStyle: WidgetStatePropertyAll(
          sans(size: 13, weight: FontWeight.w600),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: sans(size: 13.5, color: mutedLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bronze, width: 1.5),
      ),
    ),
  );
}

class MuseoBackdrop extends StatelessWidget {
  final Widget child;

  const MuseoBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (AppTheme.modo != 'light') {
      return ColoredBox(color: AppTheme.bg, child: child);
    }

    return CustomPaint(
      painter: const _FondoMuseo(),
      child: child,
    );
  }
}

class _FondoMuseo extends CustomPainter {
  const _FondoMuseo();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawColor(const Color(0xFFECE5D8), BlendMode.srcOver);

    void luz(double x, double y, double rx, double ry, Color color) {
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.scale(rx * size.width, ry * size.height);

      const circulo = Rect.fromLTRB(-1, -1, 1, 1);
      final pincel = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(circulo);

      canvas.drawOval(circulo, pincel);
      canvas.restore();
    }

    // Arena en la base, terracota a la derecha y marfil a la izquierda.
    luz(0.50, 1.00, 0.560, 0.385, const Color(0x6BBCAA92));
    luz(0.95, 0.12, 0.423, 0.325, const Color(0x38A35D38));
    luz(0.08, -0.05, 0.520, 0.358, const Color(0xFAFFFCF5));

    // Reflejos suaves en las esquinas.
    luz(0.16, 0.06, 0.080, 0.155, const Color(0x20D48652));
    luz(0.89, 0.89, 0.080, 0.155, const Color(0x22A88E6C));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_FondoMuseo oldDelegate) => false;
}

class HoverCard extends StatefulWidget {
  final Widget Function(bool hovered) builder;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? baseColor;
  final Color? hoverColor;

  const HoverCard({
    super.key,
    required this.builder,
    this.onTap,
    this.borderRadius = 22,
    this.baseColor,
    this.hoverColor,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: (_hovered ? widget.hoverColor : widget.baseColor) ?? AppTheme.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _hovered ? AppTheme.bronzeBorder : AppTheme.line,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ink.withValues(alpha: _hovered ? 0.1 : 0.045),
                blurRadius: _hovered ? 30 : 18,
                offset: Offset(0, _hovered ? 12 : 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.builder(_hovered),
        ),
      ),
    );
  }
}

class NavPillItem {
  final String id;
  final String label;
  final VoidCallback onTap;
  const NavPillItem({required this.id, required this.label, required this.onTap});
}

class MuseoFloatingBar extends StatefulWidget {
  final List<NavPillItem> items;
  final String activeId;
  final VoidCallback onLogoTap;
  final Widget trailing;

  const MuseoFloatingBar({
    super.key,
    required this.items,
    required this.activeId,
    required this.onLogoTap,
    required this.trailing,
  });

  @override
  State<MuseoFloatingBar> createState() => _MuseoFloatingBarState();
}

class _MuseoFloatingBarState extends State<MuseoFloatingBar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 760;
        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.fromLTRB(compacto ? 16 : 24, 8, compacto ? 12 : 12, 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _hovered ? AppTheme.bronzeBorder : AppTheme.surface.withValues(alpha: 0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ink.withValues(alpha: _hovered ? 0.11 : 0.07),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: widget.onLogoTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'MUSEO',
                          style: AppTheme.serif(
                            size: compacto ? 18 : 20,
                            weight: FontWeight.w700,
                            letterSpacing: compacto ? 3 : 5.5,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (compacto)
                      PopupMenuButton<int>(
                        tooltip: 'Abrir navegación',
                        icon: Icon(Icons.menu_rounded, color: AppTheme.ink),
                        onSelected: (index) => widget.items[index].onTap(),
                        itemBuilder: (_) => [
                          for (var i = 0; i < widget.items.length; i++)
                            PopupMenuItem<int>(
                              value: i,
                              child: Text(widget.items[i].label),
                            ),
                        ],
                      )
                    else ...[
                      Flexible(
                        flex: 6,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.head.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppTheme.line),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: widget.items
                                  .map((item) => _PillTab(
                                        label: item.label,
                                        active: item.id == widget.activeId,
                                        onTap: item.onTap,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      widget.trailing,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

class _PillTab extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PillTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_PillTab> createState() => _PillTabState();
}

class _PillTabState extends State<_PillTab> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
                    )
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: AppTheme.sans(
              size: 13,
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

class _Paleta {
  final Color bg, surface, ink, inkSecondary, muted, mutedLight, bronze,
      bronzeDark, bronzeLight, bronzeBorder, line, head, btn, btnTexto;

  const _Paleta({
    required this.bg, required this.surface, required this.ink,
    required this.inkSecondary, required this.muted, required this.mutedLight,
    required this.bronze, required this.bronzeDark, required this.bronzeLight,
    required this.bronzeBorder, required this.line, required this.head,
    required this.btn, required this.btnTexto,
  });

  static const clara = _Paleta(
    bg: Color(0xFFECE5D8), surface: Color(0xFFFFFFFF), ink: Color(0xFF11151C),
    inkSecondary: Color(0xFF1F2733), muted: Color(0xFF3F4856),
    mutedLight: Color(0xFF3F4856), bronze: Color(0xFF7A3817),
    bronzeDark: Color(0xFF57260E), bronzeLight: Color(0x247A3817),
    bronzeBorder: Color(0x737A3817), line: Color(0xFFD6CCBC),
    head: Color(0xFFEDE6DA), btn: Color(0xFF11151C), btnTexto: Color(0xFFFFFFFF),
  );

  static const oscura = _Paleta(
    bg: Color(0xFF0B0E14), surface: Color(0xFF141A26), ink: Color(0xFFF8FAFC),
    inkSecondary: Color(0xFFE2E8F0), muted: Color(0xFFCBD5E1),
    mutedLight: Color(0xFFCBD5E1), bronze: Color(0xFFF7B383),
    bronzeDark: Color(0xFFFFD9BE), bronzeLight: Color(0x33F7B383),
    bronzeBorder: Color(0x80F7B383), line: Color(0xFF94A3B8),
    head: Color(0xFF1B2333), btn: Color(0xFFF7B383), btnTexto: Color(0xFF0B0E14),
  );

  static const contraste = _Paleta(
    bg: Color(0xFF000000), surface: Color(0xFF000000), ink: Color(0xFFFFFFFF),
    inkSecondary: Color(0xFFFFFFFF), muted: Color(0xFFFFEA00),
    mutedLight: Color(0xFFFFEA00), bronze: Color(0xFFFFEA00),
    bronzeDark: Color(0xFFFFEA00), bronzeLight: Color(0xFF242100),
    bronzeBorder: Color(0xFFFFEA00), line: Color(0xFFFFEA00),
    head: Color(0xFF1A1A1A), btn: Color(0xFFFFEA00), btnTexto: Color(0xFF000000),
  );
}
