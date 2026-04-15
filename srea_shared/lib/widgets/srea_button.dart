import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum SreaButtonType { primary, report, update, outline, ghost }
enum SreaButtonSize { small, medium, large }

/// A reusable button widget for SREA.
///
/// Usage:
/// ```dart
/// SreaButton(label: 'Login', onPressed: () {}, fullWidth: true)
/// SreaButton(label: 'Register', onPressed: () {}, fullWidth: true)
/// SreaButton.report(label: 'Report Incident', onPressed: () {})
/// SreaButton.update(label: 'Update', onPressed: () {})
/// SreaButton.outline(label: 'Cancel', onPressed: () {})
/// ```
class SreaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SreaButtonType type;
  final SreaButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool isLoading;

  const SreaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = SreaButtonType.primary,
    this.size = SreaButtonSize.medium,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  const SreaButton.report({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
  })  : type = SreaButtonType.report,
        size = SreaButtonSize.medium;

  const SreaButton.update({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
  })  : type = SreaButtonType.update,
        size = SreaButtonSize.medium;

  const SreaButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.isLoading = false,
  })  : type = SreaButtonType.outline,
        size = SreaButtonSize.medium;

  Color get _bgColor {
    switch (type) {
      case SreaButtonType.primary:
        return SreaColors.buttonPrimary;
      case SreaButtonType.report:
        return SreaColors.buttonReport;
      case SreaButtonType.update:
        return SreaColors.buttonUpdate;
      case SreaButtonType.outline:
      case SreaButtonType.ghost:
        return Colors.transparent;
    }
  }

  Color get _fgColor {
    switch (type) {
      case SreaButtonType.outline:
        return SreaColors.primary;
      case SreaButtonType.ghost:
        return SreaColors.textSecondary;
      default:
        return SreaColors.textOnPrimary;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case SreaButtonSize.small:
        return SreaSpacing.buttonPaddingSmall;
      case SreaButtonSize.large:
        return SreaSpacing.buttonPaddingFull;
      case SreaButtonSize.medium:
        return SreaSpacing.buttonPadding;
    }
  }

  double get _fontSize {
    switch (size) {
      case SreaButtonSize.small:
        return 12;
      case SreaButtonSize.large:
        return 16;
      case SreaButtonSize.medium:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !isLoading;

    final textStyle = SreaText.label.copyWith(
      fontSize: _fontSize,
      fontWeight: FontWeight.w700,
      color: isDisabled ? SreaColors.textHint : _fgColor,
    );

    Widget content = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _fgColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isDisabled ? SreaColors.textHint : _fgColor,
                ),
                SizedBox(width: SreaSpacing.iconGap),
              ],
              Text(label, style: textStyle),
            ],
          );

    final isOutline = type == SreaButtonType.outline;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: isDisabled ? SreaColors.buttonDisabled : _bgColor,
            borderRadius: SreaRadius.button,
            border: isOutline
                ? Border.all(color: SreaColors.primary, width: 1.5)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: SreaRadius.button,
            child: InkWell(
              onTap: (isLoading || isDisabled) ? null : onPressed,
              borderRadius: SreaRadius.button,
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Padding(
                padding: _padding,
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
