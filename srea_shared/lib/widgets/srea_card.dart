import 'package:flutter/material.dart';
import '../theme/theme.dart';

// ─────────────────────────────────────────────────────────────
// SreaCard — Base reusable card container
//
// Usage:
// SreaCard(child: Text('Hello'))
// SreaCard(padding: SreaSpacing.cardPaddingSmall, onTap: () {}, child: ...)
// ─────────────────────────────────────────────────────────────
class SreaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final bool hasShadow;

  const SreaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? SreaRadius.card;

    return Material(
      color: color ?? SreaColors.surface,
      borderRadius: br,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        splashColor: SreaColors.primaryLight,
        highlightColor: SreaColors.primaryLight.withValues(alpha: 0.5),
        child: Container(
          padding: padding ?? SreaSpacing.cardPadding,
          decoration: BoxDecoration(
            borderRadius: br,
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: SreaColors.shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaAlertCard — Alert/incident card with badge and details
//
// Usage:
// SreaAlertCard(
//   title: 'Flooding in Brgy. Partida',
//   location: 'Barangay Partida',
//   time: '10 mins ago',
//   badgeType: SreaBadgeType.critical,
//   badgeLabel: 'Critical',
//   onTap: () {},
// )
// ─────────────────────────────────────────────────────────────
class SreaAlertCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final Widget badge;
  final VoidCallback? onTap;
  final IconData? icon;

  const SreaAlertCard({
    super.key,
    required this.title,
    required this.location,
    required this.time,
    required this.badge,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SreaCard(
      onTap: onTap,
      padding: SreaSpacing.cardPaddingSmall,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: SreaColors.primaryLight,
              borderRadius: SreaRadius.input,
            ),
            child: Icon(
              icon ?? Icons.warning_amber_rounded,
              color: SreaColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: SreaSpacing.avatarGap),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: SreaText.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: SreaColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: SreaSpacing.xs),
                    badge,
                  ],
                ),
                SizedBox(height: SreaSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: SreaColors.textHint,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        style: SreaText.label
                            .copyWith(color: SreaColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style:
                          SreaText.label.copyWith(color: SreaColors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaInfoCard — Simple labeled info card (e.g. weather, stats)
//
// Usage:
// SreaInfoCard(
//   title: 'Weather',
//   subtitle: 'Partly Cloudy · 28°C',
//   icon: Icons.cloud_outlined,
//   backgroundColor: SreaColors.weatherCardBg,
//   foregroundColor: SreaColors.weatherText,
// )
// ─────────────────────────────────────────────────────────────
class SreaInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const SreaInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.backgroundColor = SreaColors.surface,
    this.foregroundColor = SreaColors.textPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SreaCard(
      onTap: onTap,
      color: backgroundColor,
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 28),
          SizedBox(width: SreaSpacing.iconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SreaText.label.copyWith(
                    color: foregroundColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: SreaText.bodySmall.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: foregroundColor.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaAllClearBanner — Green banner shown when no active alerts
//
// Usage:
// SreaAllClearBanner()
// ─────────────────────────────────────────────────────────────
class SreaAllClearBanner extends StatelessWidget {
  final String message;

  const SreaAllClearBanner({
    super.key,
    this.message = 'No active alerts in your area.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SreaSpacing.cardPaddingSmall,
      decoration: BoxDecoration(
        color: SreaColors.allClearBg,
        borderRadius: SreaRadius.card,
        border: Border.all(color: SreaColors.allClearIcon.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SreaColors.allClearIcon.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: SreaColors.allClearIcon,
              size: 20,
            ),
          ),
          SizedBox(width: SreaSpacing.iconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Clear',
                  style: SreaText.bodySmall.copyWith(
                    color: SreaColors.allClearText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  message,
                  style: SreaText.label.copyWith(
                    color: SreaColors.allClearText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
