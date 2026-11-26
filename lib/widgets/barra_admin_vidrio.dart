import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'vidrio_portada.dart';

class BarraAdminVidrio extends StatelessWidget {
  final List<NavPillItem> items;
  final String activeId;
  final Widget trailing;

  const BarraAdminVidrio({super.key, required this.items,
    required this.activeId, required this.trailing});

  static const iconos = {
    'museos': Icons.account_balance_outlined, 'salas': Icons.meeting_room_outlined,
    'artistas': Icons.person_outline, 'categorias': Icons.category_outlined,
    'obras': Icons.photo_library_outlined, 'historial': Icons.history,
    'recorridos': Icons.route_outlined,
  };

  @override
  Widget build(BuildContext context) {
    TemaMuseoActivo.observar(context);
    final actual = items.firstWhere((i) => i.id == activeId);
    final ancho = (MediaQuery.sizeOf(context).width - 48).clamp(0.0, 320.0).toDouble();
    return VidrioPortada(radio: 32, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(children: [
        Expanded(child: Padding(padding: const EdgeInsets.only(left: 8),
          child: Text(actual.label, overflow: TextOverflow.ellipsis,
            style: AppTheme.serif(size: 22, weight: FontWeight.w600)))),
        trailing,
        const SizedBox(width: 8),
        MenuAnchor(
          alignmentOffset: Offset(-ancho, 8),
          style: const MenuStyle(alignment: AlignmentDirectional.bottomEnd,
            elevation: WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
            padding: WidgetStatePropertyAll(EdgeInsets.zero)),
          builder: (_, menu, _) => IconButton(
            tooltip: menu.isOpen ? 'Cerrar menú' : 'Secciones de administración',
            onPressed: menu.isOpen ? menu.close : () => menu.open(),
            icon: Icon(menu.isOpen ? Icons.close_rounded : Icons.menu_rounded,
              color: AppTheme.bronze)),
          menuChildren: [VidrioPortada(radio: 20, child: SizedBox(width: ancho,
            child: Padding(padding: const EdgeInsets.all(10), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final item in items) MenuItemButton(
                onPressed: item.id == activeId ? null : item.onTap,
                style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(0, 48))),
                leadingIcon: Icon(iconos[item.id], color: AppTheme.bronze),
                trailingIcon: item.id == activeId ? Icon(Icons.check, color: AppTheme.bronze) : null,
                child: Text(item.label, style: AppTheme.sans(size: 16)),
              )],
            )),
          ))],
        ),
      ]),
    ));
  }
}
