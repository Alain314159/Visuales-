import 'package:flutter/material.dart';

/// Helpers de utilidades para la UI
class UIHelper {
  UIHelper._();

  /// Muestra un SnackBar
  static void showSnackBar(BuildContext context, String message, {Duration? duration, SnackBarBehavior? behavior}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        behavior: behavior ?? SnackBarBehavior.fixed,
      ),
    );
  }

  /// Muestra un SnackBar con acción
  static void showSnackBarWithAction(
    BuildContext context,
    String message,
    String actionLabel,
    VoidCallback onAction, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        action: SnackBarAction(
          label: actionLabel,
          onPressed: onAction,
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Aceptar',
    String cancelLabel = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Muestra un diálogo de información
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String actionLabel = 'Aceptar',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  /// Muestra un BottomSheet
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      builder: builder,
    );
  }

  /// Obtiene el tamaño de pantalla
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (width < 600) {
      return ScreenSize.phone;
    } else if (width < 900) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  /// Verifica si es tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Verifica si es desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
}

/// Enum para tamaño de pantalla
enum ScreenSize { phone, tablet, desktop }
