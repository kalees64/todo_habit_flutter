import 'package:flutter/material.dart';

/// Strict 4pt Spacing and Radii System for TaskFlow
class AppSpacing {
  AppSpacing._();

  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;

  // Semantic mappings
  static const double screenMargin = p16;
  static const double cardPadding = p16;
  static const double itemGap = p12;
  static const double elementGap = p8;
  static const double microGap = p4;

  // Corner Radii
  static const double radiusSmall = 6.0; // Checkbox, small tags
  static const double radiusMedium = 12.0; // Inner chips, dialogs
  static const double radiusLarge = 16.0; // Cards, list items
  static const double radiusSheet = 28.0; // Modal Bottom Sheet top corners
  static const double radiusPill = 999.0; // Buttons, Streak Badges, FAB

  // Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenMargin,
    vertical: p12,
  );
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
}
