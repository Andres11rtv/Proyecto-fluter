import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Widget selectorMuseo<T>({
  Key? key,
  required List<DropdownMenuItem<T>>? items,
  required ValueChanged<T?>? onChanged,
  T? initialValue,
  Widget? hint,
  Widget? disabledHint,
  InputDecoration? decoration,
  FormFieldValidator<T>? validator,
  FormFieldSetter<T>? onSaved,
  VoidCallback? onTap,
  FocusNode? focusNode,
  bool autofocus = false,
  AutovalidateMode? autovalidateMode,
  DropdownButtonBuilder? selectedItemBuilder,
  AlignmentGeometry alignment = AlignmentDirectional.centerStart,
  bool isDense = true,
  bool isExpanded = true,
  double? itemHeight,
  EdgeInsetsGeometry? padding,
}) {
  return Builder(builder: (context) {
    final tema = Theme.of(context);
    final acento = AppTheme.bronze;
    return Theme(
      data: tema.copyWith(
        focusColor: acento.withValues(alpha: 0.14),
        hoverColor: acento.withValues(alpha: 0.10),
        highlightColor: acento.withValues(alpha: 0.12),
      ),
      child: DropdownButtonFormField<T>(
        key: key,
        items: items,
        onChanged: onChanged,
        initialValue: initialValue,
        hint: hint,
        disabledHint: disabledHint,
        decoration: decoration,
        validator: validator,
        onSaved: onSaved,
        onTap: onTap,
        focusNode: focusNode,
        autofocus: autofocus,
        autovalidateMode: autovalidateMode,
        selectedItemBuilder: selectedItemBuilder,
        alignment: alignment,
        isDense: isDense,
        isExpanded: isExpanded,
        itemHeight: itemHeight,
        padding: padding,
        dropdownColor: Color.alphaBlend(
          acento.withValues(alpha: 0.09),
          AppTheme.surface,
        ),
        borderRadius: BorderRadius.circular(18),
        elevation: 3,
        menuMaxHeight: 336,
        focusColor: acento.withValues(alpha: 0.14),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        iconEnabledColor: acento,
        style: AppTheme.sans(size: 14, color: AppTheme.ink),
      ),
    );
  });
}