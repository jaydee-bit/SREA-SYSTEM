import 'package:flutter/material.dart';

class SreaRadius {
  SreaRadius._();

  // ─── Base Values ───────────────────────────────────────────
  static const double xs = 4;   // Subtle rounding, tags, chips
  static const double sm = 8;   // Input fields
  static const double md = 12;  // Cards, modals, dialogs
  static const double lg = 16;  // Buttons, bottom sheets
  static const double xl = 24;  // Avatars, image thumbnails
  static const double full = 999; // Fully pill-shaped (FAB, badges)

  // ─── BorderRadius Shortcuts ────────────────────────────────

  // Buttons
  static BorderRadius button = BorderRadius.circular(lg);

  // Cards
  static BorderRadius card = BorderRadius.circular(md);

  // Input fields
  static BorderRadius input = BorderRadius.circular(sm);

  // Bottom sheets — only top corners rounded
  static BorderRadius bottomSheet = const BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  // Modals / Dialogs
  static BorderRadius modal = BorderRadius.circular(md);

  // Avatars / Images
  static BorderRadius avatar = BorderRadius.circular(xl);

  // Fully rounded — FAB, notification badges
  static BorderRadius pill = BorderRadius.circular(full);
}
