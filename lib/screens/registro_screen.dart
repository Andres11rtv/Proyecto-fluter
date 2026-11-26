import '../widgets/selector_museo.dart';
import 'package:flutter/material.dart';
import '../widgets/vidrio_portada.dart';
import '../theme/app_theme.dart';

class CampoRegistro {
  final String clave;
  final String etiqueta;
  final bool obligatorio;
  final int lineas;
  final Map<int, String>? opciones;
  final String? Function(String)? validar;

  const CampoRegistro(this.clave, this.etiqueta, {
    this.obligatorio = false,
    this.lineas = 1,
    this.opciones,
    this.validar,
  });
}

String? validarFecha(String texto) {
  final fecha = DateTime.tryParse(texto);
  if (fecha == null || fecha.toIso8601String().split('T').first != texto) {
    return 'Escribe una fecha válida en formato AAAA-MM-DD.';
  }
  return null;
}

class RegistroScreen extends StatefulWidget {
  final String titulo;
  final List<CampoRegistro> campos;
  final Future<void> Function(Map<String, String>) guardar;

  final VoidCallback? alGuardar;
  const RegistroScreen({
    super.key, required this.titulo, required this.campos, required this.guardar, this.alGuardar,
  });

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final formulario = GlobalKey<FormState>();
  final valores = <String, String>{};
  bool guardando = false;
  String? error;
  String imagen = '';

  Future<void> guardar() async {
    if (guardando || !formulario.currentState!.validate()) return;
    formulario.currentState!.save();
    setState(() { guardando = true; error = null; });
    try {
      await widget.guardar(valores);
    } catch (e) {
      if (mounted) setState(() { guardando = false; error = 'No se pudo guardar: $e'; });
      return;
    }
    if (!mounted) return;
    if (widget.alGuardar == null) {
      Navigator.pop(context, true);
    } else {
      setState(() { guardando = false; imagen = ''; });
      formulario.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro guardado.')));
      widget.alGuardar!();
    }
  }

  Widget campo(CampoRegistro c) {
    final opciones = c.opciones;
    const decoracion = InputDecoration();
    if (opciones != null) {
      return selectorMuseo<int>(
        decoration: decoracion,
        isExpanded: true,
        items: [
          if (!c.obligatorio) const DropdownMenuItem<int>(child: Text('Sin asignar')),
          for (final item in opciones.entries)
            DropdownMenuItem(value: item.key, child: Text(item.value)),
        ],
        onChanged: (_) {},
        validator: (id) => c.obligatorio && id == null ? 'Selecciona una opción.' : null,
        onSaved: (id) => valores[c.clave] = id?.toString() ?? '',
      );
    }
    return TextFormField(
      maxLines: c.lineas, decoration: decoracion,
      onChanged: c.clave == 'imagen_url' ? (v) => setState(() => imagen = v.trim()) : null,
      validator: (valor) {
        final texto = valor?.trim() ?? '';
        if (texto.isEmpty) return c.obligatorio ? 'Completa este campo.' : null;
        return c.validar?.call(texto);
      },
      onSaved: (v) => valores[c.clave] = v?.trim() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    Widget campos(List<CampoRegistro> lista) => Column(children: [
      for (final c in lista)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(c.etiqueta, style: AppTheme.sans(size: 13, weight: FontWeight.w600)),
            const SizedBox(height: 6),
            Semantics(label: c.etiqueta, child: campo(c)),
          ]),
        ),
      if (lista.any((c) => c.clave == 'imagen_url'))
        Container(height: 120, width: double.infinity, color: AppTheme.head,
          alignment: Alignment.center,
          child: imagen.isEmpty ? const Text('Vista previa de imagen') :
            Image.network(imagen, fit: BoxFit.contain, webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (_, _, _) => const Text('Imagen no disponible'))),
    ]);
    final panel = VidrioPortada(child: Padding(padding: const EdgeInsets.all(22), child: Form(
      key: formulario, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.titulo, style: AppTheme.serif(size: 26)),
        Divider(height: 28, color: AppTheme.line),
        LayoutBuilder(builder: (_, box) {
          final corte = widget.campos.indexWhere((c) => c.clave == 'imagen_url') + 1;
          if (box.maxWidth >= 640 && corte > 0) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: campos(widget.campos.take(corte).toList())), const SizedBox(width: 20),
              Expanded(child: campos(widget.campos.skip(corte).toList())),
            ]);
          }
          return campos(widget.campos);
        }),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        Wrap(alignment: WrapAlignment.end, spacing: 8, children: [
          OutlinedButton(onPressed: guardando ? null : () {
            formulario.currentState!.reset();
            setState(() { error = null; imagen = ''; });
          }, child: const Text('Limpiar')),
          FilledButton(onPressed: guardando ? null : guardar, child: Text(guardando ? 'Guardando…' : 'Guardar')),
        ]),
      ]),
    )));
    if (widget.alGuardar != null) return panel;
    return PopScope(canPop: !guardando, child: Scaffold(appBar: AppBar(title: const Text('Registro')),
      body: MuseoBackdrop(child: ListView(padding: const EdgeInsets.all(20), children: [panel]))));
  }
}
