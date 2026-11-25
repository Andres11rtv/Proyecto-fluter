import '../screens/historial_general_screen.dart';
import '../screens/registro_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/artistas_screen.dart';
import '../screens/categorias_screen.dart';
import '../screens/museos_screen.dart';
import '../screens/obras_screen.dart';
import '../screens/recorridos_screen.dart';
import '../screens/salas_screen.dart';
import '../theme/app_theme.dart';

String fechaCorta(DateTime d) {
  final dia = d.day.toString().padLeft(2, '0');
  final mes = d.month.toString().padLeft(2, '0');
  return '$dia/$mes/${d.year}';
}

String _normalizar(String s) {
  const con = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sin = 'aaaaeeeeiiiioooouuuun';
  var r = s.toLowerCase();
  for (var i = 0; i < con.length; i++) {
    r = r.replaceAll(con[i], sin[i]);
  }
  return r;
}

/// Pantalla base de administración: fondo, barra flotante y contenido con scroll.
class AdminShell extends StatelessWidget {
  final String activeId;
  final List<Widget> children;

  const AdminShell({super.key, required this.activeId, required this.children});

  void _ir(BuildContext context, Widget pantalla) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  NavPillItem _item(
      BuildContext context, String id, String label, Widget pantalla) {
    return NavPillItem(
      id: id,
      label: label,
      onTap: id == activeId ? () {} : () => _ir(context, pantalla),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MuseoBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Align(alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 88, 20, 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 20,
                right: 20,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: MuseoFloatingBar(
                      activeId: activeId,
                      onLogoTap: () => Navigator.pop(context),
                      items: [
                        _item(context, 'museos', 'Museos', const MuseosScreen()),
                        _item(context, 'salas', 'Salas', const SalasScreen()),
                        _item(context, 'artistas', 'Artistas',
                            const ArtistasScreen()),
                        _item(context, 'categorias', 'Categorías',
                            const CategoriasScreen()),
                        _item(context, 'obras', 'Obras', const ObrasScreen()),
                        _item(context, 'historial', 'Historial', const HistorialGeneralScreen()),
                        _item(context, 'recorridos', 'Recorridos',
                            const RecorridosScreen()),
                      ],
                      trailing: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Volver al inicio'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabecera: etiqueta "ADMINISTRACIÓN", título, subtítulo y un widget opcional a la derecha.
class AdminHead extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget? extra;

  const AdminHead({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final texto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADMINISTRACIÓN',
          style: AppTheme.sans(
            size: 11,
            weight: FontWeight.w700,
            letterSpacing: 3,
            color: AppTheme.bronze,
          ),
        ),
        const SizedBox(height: 4),
        Text(titulo, style: AppTheme.serif(size: 38, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            subtitulo,
            style:
                AppTheme.sans(size: 14.5, height: 1.6, color: AppTheme.muted),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final extraW = extra;
          if (extraW == null) return texto;
          if (constraints.maxWidth > 720) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: texto),
                const SizedBox(width: 24),
                extraW,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [texto, const SizedBox(height: 16), extraW],
          );
        },
      ),
    );
  }
}

/// Imagen decorativa para la cabecera (como el banner de la web).
class AdminBanner extends StatelessWidget {
  final String url;
  const AdminBanner({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 130,
      decoration: BoxDecoration(
        color: AppTheme.head,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.line, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Center(
          child: Icon(Icons.image_outlined, color: AppTheme.bronze, size: 32),
        ),
      ),
    );
  }
}

class KpiDato {
  final String etiqueta;
  final String valor;
  const KpiDato(this.etiqueta, this.valor);
}

/// Tarjetas de indicadores tipo "vidrio" (3 por fila en pantalla ancha).
class KpiRow extends StatelessWidget {
  final List<KpiDato> datos;
  const KpiRow({super.key, required this.datos});

  Widget _tarjeta(KpiDato d) {
    final esContraste = AppTheme.modo == 'contrast';
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: esContraste ? 0 : 16,
          sigmaY: esContraste ? 0 : 16,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: esContraste ? 1.0 : 0.78),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: esContraste
                  ? AppTheme.line
                  : AppTheme.surface.withValues(alpha: 0.9),
            ),
            boxShadow: esContraste
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.ink.withValues(alpha: 0.06),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  d.etiqueta.toUpperCase(),
                  style: AppTheme.sans(
                    size: 11.5,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppTheme.muted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                d.valor,
                style: AppTheme.serif(size: 30, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tarjetas = datos.map(_tarjeta).toList();
        if (constraints.maxWidth > 720) {
          return Row(
            children: [
              for (var i = 0; i < tarjetas.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: tarjetas[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < tarjetas.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              tarjetas[i],
            ],
          ],
        );
      },
    );
  }
}

class AdminPanel extends StatelessWidget {
  final Widget child;
  const AdminPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(22), child: child),
    );
  }
}

class AdminBuscador extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onCambio;

  const AdminBuscador({
    super.key,
    required this.controller,
    required this.hint,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        onChanged: (_) => onCambio(),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search, color: AppTheme.bronze, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: AppTheme.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: AppTheme.line),
          ),
        ),
      ),
    );
  }
}

/// Celdas listas para usar en las tablas.
class AdminCeldas {
  static DataCell titulo(String texto) => DataCell(
        Text(texto, style: AppTheme.sans(size: 13.5, weight: FontWeight.w700)),
      );

  static DataCell texto(String texto) => DataCell(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Text(
            texto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.sans(size: 13, color: AppTheme.inkSecondary),
          ),
        ),
      );
}

class AdminTabla extends StatelessWidget {
  final List<String> columnas;
  final List<DataRow> filas;

  const AdminTabla({super.key, required this.columnas, required this.filas});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
        color: AppTheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 14, horizontalMargin: 14,
                headingRowColor: WidgetStatePropertyAll(AppTheme.head),
                dataRowMinHeight: 56,
                dataRowMaxHeight: 66,
                columns: columnas
                    .map(
                      (c) => DataColumn(
                        label: Text(
                          c.toUpperCase(),
                          style: AppTheme.sans(
                            size: 11,
                            weight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                rows: filas,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminVacio extends StatelessWidget {
  const AdminVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.head,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 32, color: AppTheme.bronze),
          const SizedBox(height: 8),
          Text('Sin registros',
              style: AppTheme.serif(size: 20, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Puedes cambiar la búsqueda o crear un registro.',
            textAlign: TextAlign.center,
            style: AppTheme.sans(size: 13, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

/// Todo lo que una lista necesita una vez cargados los datos.
class AdminDatos<T> {
  final List<T> items;
  final List<KpiDato> kpis;
  final List<CampoRegistro> campos;
  final Future<void> Function(Map<String, String>) guardar;
  final String Function(T) textoBusqueda;
  final List<DataCell> Function(T) celdas;
  final Widget Function(T) detalle;

  const AdminDatos({
    required this.items,
    required this.campos,
    required this.guardar,
    required this.textoBusqueda,
    required this.celdas,
    required this.detalle,
    this.kpis = const [],
  });
}

/// Pantalla de lista completa con el diseño de administración:
/// cabecera, indicadores y tabla con acceso al formulario.
class AdminListPage<T> extends StatefulWidget {
  final String activeId;
  final String titulo;
  final String subtitulo;
  final String textoNuevo;
  final String hintBusqueda;
  final String tituloForm;
  final List<String> columnas;
  final Future<AdminDatos<T>> Function() cargar;
  final String? tituloListado;
  final String? bannerUrl;
  final bool conBuscador;

  const AdminListPage({
    super.key,
    required this.activeId,
    required this.titulo,
    required this.subtitulo,
    required this.textoNuevo,
    required this.tituloForm,
    required this.columnas,
    required this.cargar,
    this.hintBusqueda = 'Buscar...',
    this.tituloListado,
    this.bannerUrl,
    this.conBuscador = true,
  });

  @override
  State<AdminListPage<T>> createState() => _AdminListPageState<T>();
}

class _AdminListPageState<T> extends State<AdminListPage<T>> {
  late Future<AdminDatos<T>> _futuro;
  final TextEditingController _busqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futuro = widget.cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  final clavePanel = GlobalKey();
  void _irAlFormulario() {
    final panel = clavePanel.currentContext;
    if (panel != null) Scrollable.ensureVisible(panel, alignment: 0.15, duration: const Duration(milliseconds: 250));
  }

  Widget _botonNuevo() {
    return FilledButton.icon(
      onPressed: _irAlFormulario,
      icon: const Icon(Icons.add, size: 18),
      label: Text(widget.textoNuevo),
    );
  }

  Widget _contenido(AdminDatos<T> datos) {
    final q = _normalizar(_busqueda.text.trim());
    final filtradas = datos.items
        .where(
            (e) => q.isEmpty || _normalizar(datos.textoBusqueda(e)).contains(q))
        .toList();

    final herramientas = <Widget>[
      if (widget.activeId != 'categorias' && widget.activeId != 'recorridos') _botonNuevo(),
      if (widget.conBuscador)
        AdminBuscador(
          controller: _busqueda,
          hint: widget.hintBusqueda,
          onCambio: () => setState(() {}),
        ),
    ];

    final listado = AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.tituloListado != null) ...[
            Text(
              widget.tituloListado!,
              style: AppTheme.serif(size: 24, weight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
          ],
          if (herramientas.isNotEmpty) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: herramientas,
            ),
            const SizedBox(height: 16),
          ],
          if (filtradas.isEmpty)
            const AdminVacio()
          else
            AdminTabla(
              columnas: [...widget.columnas, 'Acciones'],
              filas: filtradas
                  .map(
                    (e) => DataRow(
                      cells: [
                        ...datos.celdas(e),
                        DataCell(
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => datos.detalle(e)),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            child: const Text('Ver detalle'),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (datos.kpis.isNotEmpty) KpiRow(datos: datos.kpis),
      if (datos.kpis.isNotEmpty) const SizedBox(height: 18),
      LayoutBuilder(builder: (context, box) {
        final panel = RegistroScreen(key: clavePanel, titulo: widget.tituloForm, campos: datos.campos,
          guardar: datos.guardar, alGuardar: () => setState(() => _futuro = widget.cargar()));
        if (box.maxWidth < 820) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [listado, const SizedBox(height: 20), panel]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: widget.activeId == 'categorias' ? 145 : 195, child: listado),
          const SizedBox(width: 24), Expanded(flex: 105, child: panel),
        ]);
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget? extra;
    if (widget.activeId == 'categorias' || widget.activeId == 'recorridos') {
      extra = _botonNuevo();
    } else if (widget.bannerUrl != null) {
      extra = AdminBanner(url: widget.bannerUrl!);
    }

    return AdminShell(
      activeId: widget.activeId,
      children: [
        AdminHead(
            titulo: widget.titulo, subtitulo: widget.subtitulo, extra: extra),
        const SizedBox(height: 22),
        FutureBuilder<AdminDatos<T>>(
          future: _futuro,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'Error al cargar los datos: ${snapshot.error}',
                    style: AppTheme.sans(color: AppTheme.muted),
                  ),
                ),
              );
            }
            return _contenido(snapshot.data!);
          },
        ),
      ],
    );
  }
}
