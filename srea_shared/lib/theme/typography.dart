import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SreaText {
  SreaText._();

  // ─── Headline Large ────────────────────────────────────────
  // Use: Hero sections, welcome/splash screens
  // Size: 34 | Weight: Bold (700) | Spacing: -0.5
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // ─── Headline Small ────────────────────────────────────────
  // Use: Main page titles, AppBar title
  // Size: 26 | Weight: SemiBold (600) | Spacing: -0.25
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  // ─── Title Large ───────────────────────────────────────────
  // Use: Section headers, card titles
  // Size: 20 | Weight: Medium (500) | Spacing: 0.0
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.4,
  );

  // ─── Body Large ────────────────────────────────────────────
  // Use: Main reading text, standard content
  // Size: 16 | Weight: Regular (400) | Spacing: 0.15
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  // ─── Body Small ────────────────────────────────────────────
  // Use: Supporting text, descriptions, secondary content
  // Size: 14 | Weight: Regular (400) | Spacing: 0.15
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  // ─── Label / Caption ───────────────────────────────────────
  // Use: Button text, hints, timestamps, nav labels
  // Size: 12 | Weight: Medium (500) | Spacing: 0.5
  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );
}
