import 'package:flutter/material.dart';
import '../theme/theme.dart';

// ─────────────────────────────────────────────────────────────
// SreaRadioOption — Styled radio button row
//
// Usage:
// SreaRadioOption<String>(
//   label: 'Resident of San Rafael',
//   value: 'resident',
//   groupValue: _residencyStatus,
//   onChanged: (v) => setState(() => _residencyStatus = v),
// )
// ─────────────────────────────────────────────────────────────
class SreaRadioOption<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final void Function(T?)? onChanged;
  final String? subtitle;

  const SreaRadioOption({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
  });

  bool get _isSelected => groupValue == value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isSelected ? SreaColors.primaryLight : SreaColors.surface,
          borderRadius: SreaRadius.input,
          border: Border.all(
            color: _isSelected ? SreaColors.primary : SreaColors.border,
            width: _isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Custom radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isSelected ? SreaColors.primary : SreaColors.border,
                  width: _isSelected ? 2 : 1.5,
                ),
                color: _isSelected ? SreaColors.primary : SreaColors.surface,
              ),
              child: _isSelected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: SreaColors.textOnPrimary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: SreaSpacing.iconGap),
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SreaText.bodySmall.copyWith(
                      color: _isSelected
                          ? SreaColors.primary
                          : SreaColors.textPrimary,
                      fontWeight: _isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: SreaText.label.copyWith(
                        color: SreaColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaRadioGroup — Group of radio options with a label
//
// Usage:
// SreaRadioGroup<String>(
//   label: 'Residency Status',
//   groupValue: _status,
//   onChanged: (v) => setState(() => _status = v),
//   options: [
//     SreaRadioItem(label: 'Resident of San Rafael', value: 'resident'),
//     SreaRadioItem(label: 'Non-Resident', value: 'non_resident'),
//   ],
// )
// ─────────────────────────────────────────────────────────────
class SreaRadioItem<T> {
  final String label;
  final T value;
  final String? subtitle;

  const SreaRadioItem({
    required this.label,
    required this.value,
    this.subtitle,
  });
}

class SreaRadioGroup<T> extends StatelessWidget {
  final String? label;
  final T? groupValue;
  final void Function(T?)? onChanged;
  final List<SreaRadioItem<T>> options;

  const SreaRadioGroup({
    super.key,
    this.label,
    required this.groupValue,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: SreaText.bodySmall.copyWith(
              color: SreaColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SreaSpacing.inputLabelGap),
        ],
        ...options.map((option) => Padding(
              padding: EdgeInsets.only(
                bottom: option != options.last ? SreaSpacing.sm : 0,
              ),
              child: SreaRadioOption<T>(
                label: option.label,
                value: option.value,
                groupValue: groupValue,
                onChanged: onChanged,
                subtitle: option.subtitle,
              ),
            )),
      ],
    );
  }
}
