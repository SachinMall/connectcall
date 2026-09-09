import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.12),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}
