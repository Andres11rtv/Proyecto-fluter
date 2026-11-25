import '../rutas_museo.dart';
import '../widgets/imagen_obra.dart';
import 'historial_general_screen.dart';
import 'registro_screen.dart';
import 'package:flutter/material.dart';
import '../services/eliminacion_service.dart';
import '../widgets/papelera_registro.dart';
import '../widgets/vidrio_portada.dart';
import '../widgets/barra_admin_vidrio.dart';

import '../models/artista.dart';
import '../models/categoria.dart';
import '../models/obra.dart';
import '../models/sala.dart';
import '../services/contract/artista_service.dart';
import '../services/artista_service_impl.dart';
import '../services/contract/categoria_service.dart';
import '../services/categoria_service_impl.dart';
import '../services/contract/obra_service.dart';
import '../services/obra_service_impl.dart';
import '../services/contract/sala_service.dart';
import '../services/sala_service_impl.dart';
import '../theme/app_theme.dart';
import 'artistas_screen.dart';
import 'categorias_screen.dart';
import 'museos_screen.dart';
import 'obra_detalle_screen.dart';
import 'recorridos_screen.dart';
import 'salas_screen.dart';

class ObrasScreen extends StatefulWidget {
  final String busquedaInicial;

  const ObrasScreen({super.key, this.busquedaInicial = ''});

  @override
  State<ObrasScreen> createState() => _ObrasScreenState();
}

class _ObrasScreenState extends State<ObrasScreen> {
  final ObraService _obraService = ObraServiceImpl();
  final CategoriaService _categoriaService = CategoriaServiceImpl();
  final ArtistaService _artistaService = ArtistaServiceImpl();
  final SalaService _salaService = SalaServiceImpl();

  late final TextEditingController _searchCtrl;
  List<Obra> _obras = [];
  List<Categoria> _categorias = [];
  List<Artista> _artistas = [];
  List<Sala> _salas = [];

  int? _filtroCategoria;
  int? _filtroArtista;
  int? _filtroSala;
  String? _error;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.busquedaInicial);
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    try {
    final res = await Future.wait([
      _obraService.obtenerObras(),
      _categoriaService.obtenerCategorias(),
      _artistaService.obtenerArtistas(),
      _salaService.obtenerSalas(),
    ]);
    if (!mounted) return;
    setState(() {
      _error = null;
      _obras = res[0] as List<Obra>;
      _categorias = res[1] as List<Categoria>;
      _artistas = res[2] as List<Artista>;
      _salas = res[3] as List<Sala>;
      _cargando = false;
    });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _cargando = false; });
    }
  }

  List<Obra> get _filtradas {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _obras.where((o) {
      final okCat =
          _filtroCategoria == null || o.idCategoria == _filtroCategoria;
      final okArt = _filtroArtista == null || o.idArtista == _filtroArtista;
      final okSal = _filtroSala == null || o.idSala == _filtroSala;
      final okTxt =
          q.isEmpty ||
          o.nombre.toLowerCase().contains(q) ||
          o.descripcion.toLowerCase().contains(q);
      return okCat && okArt && okSal && okTxt;
    }).toList();
  }

  String _nombreCat(int id) =>
      _categorias.where((c) => c.id == id).map((c) => c.nombre).firstOrNull ??
      '—';
  String _nombreArt(int? id) => id == null
      ? 'Sin atribuir'
      : _artistas.where((a) => a.id == id).map((a) => a.nombre).firstOrNull ??
            '—';
  String _nombreSala(int? id) => id == null
      ? 'Sin sala'
      : _salas.where((s) => s.id == id).map((s) => s.nombre).firstOrNull ?? '—';

  void _navegar(Widget pantalla) {
    Navigator.pushReplacement(
      context,
      rutaMuseo(pantalla),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MuseoBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _cargando
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: TextButton(onPressed: _cargarTodo, child: Text('Error al cargar: $_error. Reintentar')))
                      : LayoutBuilder(builder: (context, box) {
                  final margen = (box.maxWidth - 1080) / 2;
                  final lateral = 20.0 + (margen > 0 ? margen : 0.0);
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(lateral, 88, lateral, 44),
                    child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHead(),
                              const SizedBox(height: 22),
                              _buildToolbar(),
                              const SizedBox(height: 16),
                              _buildTablaObras(),
                              const SizedBox(height: 20),
                              _formularioObra(),
                            ],
                          ),
                  );
                })),
              Positioned(
                top: 14,
                left: 20,
                right: 20,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: BarraAdminVidrio(
                      activeId: 'obras',
                      
                      items: [
                        NavPillItem(
                          id: 'museos',
                          label: 'Museos',
                          onTap: () => _navegar(const MuseosScreen()),
                        ),
                        NavPillItem(
                          id: 'salas',
                          label: 'Salas',
                          onTap: () => _navegar(const SalasScreen()),
                        ),
                        NavPillItem(
                          id: 'artistas',
                          label: 'Artistas',
                          onTap: () => _navegar(const ArtistasScreen()),
                        ),
                        NavPillItem(
                          id: 'categorias',
                          label: 'Categorías',
                          onTap: () => _navegar(const CategoriasScreen()),
                        ),
                        NavPillItem(id: 'obras', label: 'Obras', onTap: () {}),
                        NavPillItem(id: 'historial', label: 'Historial',
                          onTap: () => _navegar(const HistorialGeneralScreen())),
                        NavPillItem(
                          id: 'recorridos',
                          label: 'Recorridos',
                          onTap: () => _navegar(const RecorridosScreen()),
                        ),
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

  final claveRegistro = GlobalKey();
  Widget _formularioObra() {
    return RegistroScreen(key: claveRegistro, alGuardar: _cargarTodo, titulo: 'Nueva obra', campos: [
        const CampoRegistro('nombre', 'Nombre de la obra', obligatorio: true),
        const CampoRegistro('descripcion', 'Descripción', lineas: 3),
        const CampoRegistro('imagen_url', 'URL de la imagen'),
        const CampoRegistro('creacion', 'Creación (AAAA-MM-DD)', obligatorio: true, validar: validarFecha),
        const CampoRegistro('adquisicion', 'Adquisición (AAAA-MM-DD)', obligatorio: true, validar: validarFecha),
        CampoRegistro('porcentaje_de_condicion', 'Conservación (%)', obligatorio: true, validar: (v) {
              final n = int.tryParse(v);
              return n == null || n < 0 || n > 100 ? 'Valor fuera de rango.' : null;
            }),
        CampoRegistro('id_categoria', 'Categoría', obligatorio: true, opciones: {for (final item in _categorias) item.id: item.nombre}),
        CampoRegistro('id_artistas', 'Artista', opciones: {for (final item in _artistas) item.id: item.nombre}),
        CampoRegistro('id_exhibicion', 'Sala', opciones: {for (final item in _salas) item.id: item.nombre}),
      ], guardar: _obraService.registrar);
  }

  Widget _buildHead() {
    return Container(
      padding: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: Column(
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
          Text(
            'Obras y piezas del museo',
            style: AppTheme.serif(size: 38, weight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Inventario general de artefactos, estado de conservación y ubicación en sala.',
            style: AppTheme.sans(size: 14.5, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar obras...',
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
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: _filtroCategoria,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            hint: const Text('Categoría'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              ..._categorias.map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.nombre, overflow: TextOverflow.ellipsis)),
              ),
            ],
            onChanged: (v) => setState(() => _filtroCategoria = v),
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: _filtroArtista,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            hint: const Text('Artista'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ..._artistas.map(
                (a) => DropdownMenuItem(value: a.id, child: Text(a.nombre, overflow: TextOverflow.ellipsis)),
              ),
            ],
            onChanged: (v) => setState(() => _filtroArtista = v),
          ),
        ),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: _filtroSala,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            hint: const Text('Sala'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              ..._salas.map(
                (s) => DropdownMenuItem(value: s.id, child: Text(s.nombre, overflow: TextOverflow.ellipsis)),
              ),
            ],
            onChanged: (v) => setState(() => _filtroSala = v),
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            final panel = claveRegistro.currentContext;
            if (panel != null) Scrollable.ensureVisible(panel, alignment: 0.14, duration: const Duration(milliseconds: 250));
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Ir al formulario'),
        ),
      ],
    );
  }

  Widget _buildTablaObras() {
    final lista = _filtradas;
    return VidrioPortada(radio: 18,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1030),
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(AppTheme.head),
            dataRowMinHeight: 58,
            dataRowMaxHeight: 66,
            columns: [
              DataColumn(
                label: Text(
                  'IMAGEN',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'OBRA Y DESCRIPCIÓN',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'CATEGORÍA',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ARTISTA',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'SALA ACTUAL',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'CONSERVACIÓN',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACCIONES',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
            rows: lista.map((obra) {
              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      width: 46,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.head,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.line),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ImagenObra(url: obra.imagenUrl, nombre: obra.nombre, miniatura: true),
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          obra.nombre,
                          style: AppTheme.sans(
                            size: 13.5,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          obra.descripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sans(size: 12, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      _nombreCat(obra.idCategoria),
                      style: AppTheme.sans(size: 13),
                    ),
                  ),
                  DataCell(
                    Text(
                      _nombreArt(obra.idArtista),
                      style: AppTheme.sans(size: 13),
                    ),
                  ),
                  DataCell(
                    Text(
                      _nombreSala(obra.idSala),
                      style: AppTheme.sans(size: 13),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bronzeLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${obra.porcentajeConservacion}%',
                        style: AppTheme.sans(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppTheme.bronzeDark,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          rutaMuseo(ObraDetalleScreen(obra: obra)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: const Text('Ver ficha'),
                    ),
                    PapeleraRegistro(tipo: RegistroMuseo.obras, id: obra.id, nombre: obra.nombre,
                      alEliminar: () { if (mounted) _cargarTodo(); }),
                  ])),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

}
