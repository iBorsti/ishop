import 'package:flutter/material.dart';

/// Paleta oficial iShop (extendida y cerrada)
class IShopColors {
  static const Color primary = Color(0xFF1EC6B1); // Turquesa (acción segura)
  static const Color confirm = Color(0xFF2ECC71); // Verde (confirmación)
  static const Color warning = Color(0xFFFFC93C); // Amarillo (atención suave)
  static const Color danger = Color(0xFFFF6B6B); // Coral (riesgo/deuda)
  static const Color navy = Color(0xFF1B1F3B); // Texto/estructura
  static const Color info = Color(0xFF4A90E2); // Azul suave informativo
  static const Color background = Color(0xFFF4F4F4); // Fondo
  static const Color disabled = Color(0xFFB0B0B0); // Estados inactivos
}

/// Compatibilidad con la paleta anterior dentro del proyecto
class AppColors {
  static const Color primaryBlue = IShopColors.primary; // acciones iniciar/aceptar
  static const Color navy = IShopColors.navy; // textos
  static const Color turquoise = IShopColors.primary; // alias de acción segura
  static const Color successGreen = IShopColors.confirm; // confirmaciones
  static const Color warningYellow = IShopColors.warning; // atención suave
  static const Color coral = IShopColors.danger; // deuda/alerta
  static const Color secondaryBlue = IShopColors.info; // informativo/links
  static const Color background = IShopColors.background;
  static const Color cardWhite = Colors.white;
  static const Color warningOrange = IShopColors.warning; // mantener compat
  static const Color textDark = IShopColors.navy;
  static const Color textGray = Color(0xFF4B5563);
  static const Color info = IShopColors.info;
  static const Color disabled = IShopColors.disabled;
  // semantic helpers
  static const Color onPrimary = Colors.white;
  static const Color surface = Color(0xFFFFFFFF);
}
