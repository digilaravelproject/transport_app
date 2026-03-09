import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class CustomSnackbar {
  /// Generic method so all snackbar styles are consistent
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    // Auto-adjust text color for readability
    final Color effectiveTextColor =
        textColor ?? (backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white);

    // Using a more stable check to prevent LateInitializationError
    try {
      if (Get.isSnackbarOpen) {
        // Only attempt to close if we are certain it's initialized
        Get.closeCurrentSnackbar();
      }
    } catch (e) {
      debugPrint('Snackbar close error: $e');
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: effectiveTextColor,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: Icon(icon, color: effectiveTextColor),
      shouldIconPulse: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Iconsax.tick_circle,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.errorColor,
      icon: Iconsax.danger,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Iconsax.info_circle,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Iconsax.warning_2,
    );
  }
}
