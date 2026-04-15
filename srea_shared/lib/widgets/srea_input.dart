import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

// ─────────────────────────────────────────────────────────────
// Shared input decoration factory
// ─────────────────────────────────────────────────────────────
InputDecoration _sreaInputDecoration({
  required String hint,
  IconData? prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: SreaText.bodySmall.copyWith(color: SreaColors.textHint),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, size: 18, color: SreaColors.textHint)
        : null,
    suffixIcon: suffix,
    contentPadding: SreaSpacing.inputPadding,
    filled: true,
    fillColor: SreaColors.surface,
    enabledBorder: OutlineInputBorder(
      borderRadius: SreaRadius.input,
      borderSide: const BorderSide(color: SreaColors.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: SreaRadius.input,
      borderSide: const BorderSide(color: SreaColors.borderFocused, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: SreaRadius.input,
      borderSide: const BorderSide(color: SreaColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: SreaRadius.input,
      borderSide: const BorderSide(color: SreaColors.error, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: SreaRadius.input,
      // ignore: deprecated_member_use
      borderSide: BorderSide(color: SreaColors.border.withOpacity(0.5), width: 1),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Shared label widget used above every input
// ─────────────────────────────────────────────────────────────
class SreaInputLabel extends StatelessWidget {
  final String label;
  final bool required;

  const SreaInputLabel({super.key, required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: SreaText.bodySmall.copyWith(
          color: SreaColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: SreaText.bodySmall.copyWith(color: SreaColors.error),
                )
              ]
            : [],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaTextField — Standard text input
//
// Usage:
// SreaTextField(label: 'First Name', hint: 'Enter first name', controller: _ctrl)
// SreaTextField(label: 'Contact', hint: '09XXXXXXXXX', keyboardType: TextInputType.phone)
// ─────────────────────────────────────────────────────────────
class SreaTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final IconData? prefixIcon;
  final int? maxLines;
  final bool required;

  const SreaTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.enabled = true,
    this.prefixIcon,
    this.maxLines = 1,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          SreaInputLabel(label: label!, required: required),
          SizedBox(height: SreaSpacing.inputLabelGap),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          enabled: enabled,
          maxLines: maxLines,
          style: SreaText.bodySmall.copyWith(color: SreaColors.textPrimary),
          decoration: _sreaInputDecoration(
            hint: hint,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaPasswordField — Password input with show/hide toggle
//
// Usage:
// SreaPasswordField(label: 'Password', hint: 'Enter password', controller: _ctrl)
// ─────────────────────────────────────────────────────────────
class SreaPasswordField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool required;

  const SreaPasswordField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.required = false,
  });

  @override
  State<SreaPasswordField> createState() => _SreaPasswordFieldState();
}

class _SreaPasswordFieldState extends State<SreaPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          SreaInputLabel(label: widget.label!, required: widget.required),
          SizedBox(height: SreaSpacing.inputLabelGap),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: SreaText.bodySmall.copyWith(color: SreaColors.textPrimary),
          decoration: _sreaInputDecoration(
            hint: widget.hint,
            prefixIcon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: SreaColors.textHint,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaDropdown — Dropdown / select field
//
// Usage:
// SreaDropdown<String>(
//   label: 'Gender',
//   hint: 'Choose your Gender',
//   value: _gender,
//   items: ['Male', 'Female', 'Other'],
//   onChanged: (v) => setState(() => _gender = v),
// )
// ─────────────────────────────────────────────────────────────
class SreaDropdown<T> extends StatelessWidget {
  final String hint;
  final String? label;
  final T? value;
  final List<T> items;
  final String Function(T)? itemLabel;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool required;

  const SreaDropdown({
    super.key,
    required this.hint,
    required this.items,
    this.label,
    this.value,
    this.itemLabel,
    this.onChanged,
    this.validator,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          SreaInputLabel(label: label!, required: required),
          SizedBox(height: SreaSpacing.inputLabelGap),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          validator: validator,
          onChanged: onChanged,
          style: SreaText.bodySmall.copyWith(color: SreaColors.textPrimary),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: SreaColors.textHint),
          decoration: _sreaInputDecoration(hint: hint),
          items: items.map((item) {
            final label = itemLabel != null ? itemLabel!(item) : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Text(label,
                  style: SreaText.bodySmall
                      .copyWith(color: SreaColors.textPrimary)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
