import 'package:flutter/material.dart';

/// MaintSys Design Tokens
/// Baseado no tema escuro industrial do Figma Make
class MaintSysColors {
  // Background
  static const background = Color(0xFF0F1117);
  static const surface = Color(0xFF1A1D27);
  static const surfaceVariant = Color(0xFF252836);
  static const cardBg = Color(0xFF1E2130);

  // Brand
  static const primary = Color(0xFF3B82F6);       // Azul principal
  static const primaryDark = Color(0xFF1D4ED8);
  static const accent = Color(0xFF06B6D4);         // Cyan accent

  // Status
  static const statusOk = Color(0xFF22C55E);       // Verde - operacional
  static const statusWarn = Color(0xFFF59E0B);     // Amarelo - alerta
  static const statusError = Color(0xFFEF4444);    // Vermelho - crítico
  static const statusIdle = Color(0xFF6B7280);     // Cinza - inativo
  static const statusMaint = Color(0xFFA855F7);    // Roxo - em manutenção

  // Text
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF475569);

  // Border
  static const border = Color(0xFF2D3748);
  static const borderFocus = Color(0xFF3B82F6);
}

class MaintSysTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MaintSysColors.background,
      colorScheme: const ColorScheme.dark(
        surface: MaintSysColors.surface,
        primary: MaintSysColors.primary,
        secondary: MaintSysColors.accent,
        error: MaintSysColors.statusError,
        onSurface: MaintSysColors.textPrimary,
        onPrimary: Colors.white,
      ),
      cardTheme: const CardThemeData(
        color: MaintSysColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: MaintSysColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MaintSysColors.surface,
        foregroundColor: MaintSysColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: MaintSysColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: MaintSysColors.surface,
        selectedItemColor: MaintSysColors.primary,
        unselectedItemColor: MaintSysColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MaintSysColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MaintSysColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MaintSysColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MaintSysColors.borderFocus, width: 1.5),
        ),
        labelStyle: const TextStyle(color: MaintSysColors.textSecondary),
        hintStyle: const TextStyle(color: MaintSysColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MaintSysColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: MaintSysColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: TextStyle(
          color: MaintSysColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleLarge: TextStyle(
          color: MaintSysColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: MaintSysColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: MaintSysColors.textPrimary,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: MaintSysColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: MaintSysColors.textMuted,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: MaintSysColors.textMuted,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: MaintSysColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Utilitário: converte status string → Color
Color machineStatusColor(String status) {
  return switch (status.toLowerCase()) {
    'active' => MaintSysColors.statusOk,
    'maintenance' => MaintSysColors.statusMaint,
    _ => MaintSysColors.statusIdle, // inactive
  };
}

/// Badge de status da máquina (reutilizável)
class MachineStatusBadge extends StatelessWidget {
  final String status;
  const MachineStatusBadge({super.key, required this.status});

  String _label() => switch (status.toLowerCase()) {
    'active' => 'Operacional',
    'maintenance' => 'Em Manutenção',
    _ => 'Inativo',
  };

  @override
  Widget build(BuildContext context) {
    final color = machineStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
