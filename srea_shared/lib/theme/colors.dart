import 'package:flutter/material.dart';

class SreaColors {
  SreaColors._();

  // ─── Primary Brand ─────────────────────────────────────────
  // Main blue used in AppBar, sidebar, bottom nav, buttons
  static const Color primary        = Color(0xFF2B4EFF); // Enhanced from design
  static const Color primaryDark    = Color(0xFF1A3ADB); // Pressed / active state
  static const Color primaryLight   = Color(0xFFEEF1FF); // Background tints, chips

  // ─── Background ────────────────────────────────────────────
  static const Color background     = Color(0xFFF8F9FF); // Screen background
  static const Color surface        = Color(0xFFFFFFFF); // Cards, modals, sheets
  static const Color surfaceVariant = Color(0xFFF0F2FB); // Input fields, list rows

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF0D0F1C); // Main text
  static const Color textSecondary  = Color(0xFF5C6080); // Supporting / subtitle text
  static const Color textHint       = Color(0xFFAAADB8); // Placeholder, disabled text
  static const Color textOnPrimary  = Color(0xFFFFFFFF); // Text on blue backgrounds
  static const Color textOnDark     = Color(0xFFFFFFFF); // Text on dark surfaces

  // ─── Sidebar ───────────────────────────────────────────────
  static const Color sidebarBg     = Color(0xFF2B4EFF); // Sidebar background
  static const Color sidebarItem   = Color(0xFFFFFFFF); // Sidebar icons & text
  static const Color sidebarActive = Color(0xFF1A3ADB); // Active sidebar item

  // ─── Bottom Navigation ─────────────────────────────────────
  static const Color bottomNavBg       = Color(0xFF2B4EFF); // Nav bar background
  static const Color bottomNavActive   = Color(0xFFFFFFFF); // Selected icon
  static const Color bottomNavInactive = Color(0xFFBBC4FF); // Unselected icon

  // ─── Action Buttons ────────────────────────────────────────
  static const Color buttonPrimary  = Color(0xFF2B4EFF); // Standard CTA button
  static const Color buttonReport   = Color(0xFFFF3B30); // Report an Incident (red)
  static const Color buttonUpdate   = Color(0xFF34C759); // Update / confirm (green)
  static const Color buttonDisabled = Color(0xFFCDD0E3); // Disabled state

  // ─── FAB (Emergency Call) ──────────────────────────────────
  static const Color fab            = Color(0xFFFF3B30); // Red floating action button
  static const Color fabIcon        = Color(0xFFFFFFFF); // Icon on FAB

  // ─── Status — Alert Levels ─────────────────────────────────
  // Based on risk level color coding in your design
  static const Color critical       = Color(0xFFFF3B30); // Critical — Red
  static const Color high           = Color(0xFFFF6B2B); // High — Orange
  static const Color medium         = Color(0xFFFFCC00); // Medium — Yellow
  static const Color low            = Color(0xFF34C759); // Low — Green

  // Alert background tints (for cards / banners)
  static const Color criticalBg     = Color(0xFFFFEDEC);
  static const Color highBg         = Color(0xFFFFF0EA);
  static const Color mediumBg       = Color(0xFFFFFBE6);
  static const Color lowBg          = Color(0xFFEAF9EE);

  // ─── Status — General ──────────────────────────────────────
  static const Color success        = Color(0xFF34C759); // Success states
  static const Color warning        = Color(0xFFFFCC00); // Warning states
  static const Color error          = Color(0xFFFF3B30); // Error states
  static const Color info           = Color(0xFF2B4EFF); // Info states

  // ─── All Clear Banner ──────────────────────────────────────
  static const Color allClearBg     = Color(0xFFDFF5E3); // Light green background
  static const Color allClearIcon   = Color(0xFF34C759); // Green checkmark circle
  static const Color allClearText   = Color(0xFF1A7A36); // Dark green text

  // ─── Weather Card ──────────────────────────────────────────
  static const Color weatherCardBg  = Color(0xFF2B4EFF); // Blue card background
  static const Color weatherText    = Color(0xFFFFFFFF); // White text on card

  // ─── Incident Status Tags ──────────────────────────────────
  static const Color tagUnderReview = Color(0xFFFF6B2B); // Under Review — orange
  static const Color tagResolved    = Color(0xFF34C759); // Resolved — green
  static const Color tagPending     = Color(0xFFFFCC00); // Pending — yellow
  static const Color tagRejected    = Color(0xFFFF3B30); // Rejected — red

  // Tag background tints
  static const Color tagUnderReviewBg = Color(0xFFFFF0EA);
  static const Color tagResolvedBg    = Color(0xFFEAF9EE);
  static const Color tagPendingBg     = Color(0xFFFFFBE6);
  static const Color tagRejectedBg    = Color(0xFFFFEDEC);

  // ─── Divider & Border ──────────────────────────────────────
  static const Color divider        = Color(0xFFE4E7F0); // Subtle divider lines
  static const Color border         = Color(0xFFD0D4E8); // Input borders, card borders
  static const Color borderFocused  = Color(0xFF2B4EFF); // Focused input border

  // ─── Overlay ───────────────────────────────────────────────
  static const Color overlay        = Color(0x802B4EFF); // Modal scrim overlay
  static const Color shadowColor    = Color(0x1A2B4EFF); // Soft blue-tinted shadow
}
