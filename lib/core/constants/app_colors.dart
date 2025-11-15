import 'package:flutter/material.dart';

/// 🎨 Paleta de colores global de la app
class AppColors {
  AppColors._(); // Evita instanciación

  // ─────────────────────────────
  // 🔴 Colores principales
  // ─────────────────────────────
  static const Color primary = Colors.redAccent;
  static const Color secondary = Colors.black;
  static const Color background = Color(0xFF121212); // fondo app
  static const Color backgroundDark = Color(0xFF0D0D0D);

  // ─────────────────────────────
  // 🔤 Texto
  // ─────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textDisabled = Colors.white38;

  // ─────────────────────────────
  // 🟢 Estados
  // ─────────────────────────────
  static const Color success = Colors.greenAccent;
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.amberAccent;

  // ─────────────────────────────
  // 🧩 Componentes UI
  // ─────────────────────────────
  static const Color card = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF181818);
  static const Color divider = Colors.white24;

  // Campos de texto
  static const Color inputFill = Color(0xFF1A1A1A);
}
