import 'package:flutter/material.dart';
import 'app_colors.dart';

///  Estilos de texto globales
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle hint = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );
}
