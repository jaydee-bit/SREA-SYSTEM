import 'package:flutter/material.dart';
import '../theme/theme.dart';

// ─────────────────────────────────────────────────────────────
// Risk level and status badge types
// ─────────────────────────────────────────────────────────────
enum SreaBadgeType {
  critical,
  high,
  medium,
  low,
  underReview,
  resolved,
  pending,
  rejected,
  info,
  custom,
}

// ─────────────────────────────────────────────────────────────
// SreaBadge — Risk level / status tag
//
// Usage:
// SreaBadge(type: SreaBadgeType.critical, label: 'Critical')
// SreaBadge(type: SreaBadgeType.resolved, label: 'Resolved')
// SreaBadge(type: SreaBadgeType.pending, label: 'Pending')
// SreaBadge.custom(label: 'Custom', color: Colors.purple, bgColor: Colors.purple.shade50)
// ─────────────────────────────────────────────────────────────
class SreaBadge extends StatelessWidget {
  final SreaBadgeType type;
  final String label;
  final bool showDot;
  final Color? customColor;
  final Color? customBgColor;

  const SreaBadge({
    super.key,
    required this.type,
    required this.label,
    this.showDot = true,
    this.customColor,
    this.customBgColor,
  });

  const SreaBadge.custom({
    super.key,
    required this.label,
    required Color color,
    required Color bgColor,
    this.showDot = true,
  })  : type = SreaBadgeType.custom,
        customColor = color,
        customBgColor = bgColor;

  Color get _color {
    if (type == SreaBadgeType.custom) return customColor!;
    switch (type) {
      case SreaBadgeType.critical:
        return SreaColors.critical;
      case SreaBadgeType.high:
        return SreaColors.high;
      case SreaBadgeType.medium:
        return SreaColors.medium;
      case SreaBadgeType.low:
        return SreaColors.low;
      case SreaBadgeType.underReview:
        return SreaColors.tagUnderReview;
      case SreaBadgeType.resolved:
        return SreaColors.tagResolved;
      case SreaBadgeType.pending:
        return SreaColors.tagPending;
      case SreaBadgeType.rejected:
        return SreaColors.tagRejected;
      case SreaBadgeType.info:
        return SreaColors.primary;
      default:
        return SreaColors.primary;
    }
  }

  Color get _bgColor {
    if (type == SreaBadgeType.custom) return customBgColor!;
    switch (type) {
      case SreaBadgeType.critical:
        return SreaColors.criticalBg;
      case SreaBadgeType.high:
        return SreaColors.highBg;
      case SreaBadgeType.medium:
        return SreaColors.mediumBg;
      case SreaBadgeType.low:
        return SreaColors.lowBg;
      case SreaBadgeType.underReview:
        return SreaColors.tagUnderReviewBg;
      case SreaBadgeType.resolved:
        return SreaColors.tagResolvedBg;
      case SreaBadgeType.pending:
        return SreaColors.tagPendingBg;
      case SreaBadgeType.rejected:
        return SreaColors.tagRejectedBg;
      case SreaBadgeType.info:
        return SreaColors.primaryLight;
      default:
        return SreaColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: SreaRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: SreaText.label.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Convenience factory methods for common badges
// ─────────────────────────────────────────────────────────────
class SreaBadges {
  SreaBadges._();

  static Widget critical([String label = 'Critical']) =>
      SreaBadge(type: SreaBadgeType.critical, label: label);

  static Widget high([String label = 'High']) =>
      SreaBadge(type: SreaBadgeType.high, label: label);

  static Widget medium([String label = 'Medium']) =>
      SreaBadge(type: SreaBadgeType.medium, label: label);

  static Widget low([String label = 'Low']) =>
      SreaBadge(type: SreaBadgeType.low, label: label);

  static Widget underReview([String label = 'Under Review']) =>
      SreaBadge(type: SreaBadgeType.underReview, label: label);

  static Widget resolved([String label = 'Resolved']) =>
      SreaBadge(type: SreaBadgeType.resolved, label: label);

  static Widget pending([String label = 'Pending']) =>
      SreaBadge(type: SreaBadgeType.pending, label: label);

  static Widget rejected([String label = 'Rejected']) =>
      SreaBadge(type: SreaBadgeType.rejected, label: label);
}
