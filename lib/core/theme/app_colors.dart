import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF4F46E5);
  static const Color accent = Color(0xFF7C3AED);
  static const Color cyan = Color(0xFF22D3EE);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color online = success;
  static const Color offline = Color(0xFF94A3B8);
  static const Color missed = error;

  static const List<Color> brandGradient = [primary, secondary, accent];

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color darkBase = Color(0xFF020617);
  static const Color darkSurfaceDeep = Color(0xFF0F172A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E293B);

  static const Color darkBackground = darkBase;
  static const Color darkSurface = Color(0xFF111827);

  static const Color callScreenBackground = Color(0xFF060B18);
}
