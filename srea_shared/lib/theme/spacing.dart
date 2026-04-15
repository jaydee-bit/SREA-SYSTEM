import 'package:flutter/material.dart';

class SreaSpacing {
  SreaSpacing._();

  // ─── Base Scale ────────────────────────────────────────────
  // Built on a 4pt grid — every value is a multiple of 4
  static const double xs  = 4;   // Tight inline gaps
  static const double sm  = 8;   // Small gaps between elements
  static const double md  = 16;  // Standard padding inside containers
  static const double lg  = 24;  // Section spacing, card padding
  static const double xl  = 32;  // Large section gaps
  static const double xxl = 48;  // Hero/splash screen spacing

  // ─── Screen / Page ─────────────────────────────────────────

  // Outer horizontal padding for all screens
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  // Padding for scrollable screen content
  static const EdgeInsets screenScrollPadding = EdgeInsets.fromLTRB(
    20, 16, 20, 32,
  );

  // ─── AppBar ────────────────────────────────────────────────
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(
    horizontal: 20,
  );

  // ─── Cards ─────────────────────────────────────────────────
  // Standard padding inside a card
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  // Compact card — for list items or small info cards
  static const EdgeInsets cardPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // Gap between cards in a list or grid
  static const double cardGap = 12;

  // ─── Buttons ───────────────────────────────────────────────
  // Standard button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 14,
  );

  // Small button padding
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  // Full-width button padding
  static const EdgeInsets buttonPaddingFull = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  // ─── Input Fields ──────────────────────────────────────────
  // Padding inside text fields
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );

  // Gap between input fields in a form
  static const double inputGap = 16;

  // Gap between label and input field
  static const double inputLabelGap = 6;

  // ─── Section ───────────────────────────────────────────────
  // Padding around a full section block
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    vertical: 24,
  );

  // Gap between section header and its content
  static const double sectionHeaderGap = 12;

  // Gap between sections on a page
  static const double sectionGap = 32;

  // ─── List Items ────────────────────────────────────────────
  // Padding for each row in a list
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );

  // Gap between list items
  static const double listItemGap = 8;

  // ─── Bottom Navigation ─────────────────────────────────────
  static const EdgeInsets bottomNavPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 8,
  );

  // ─── Bottom Sheet ──────────────────────────────────────────
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(
    20, 24, 20, 32,
  );

  // ─── Modal / Dialog ────────────────────────────────────────
  static const EdgeInsets modalPadding = EdgeInsets.all(24);

  // ─── Avatar / Icon ─────────────────────────────────────────
  static const double avatarGap = 12; // Gap between avatar and text
  static const double iconGap   = 8;  // Gap between icon and label
}
