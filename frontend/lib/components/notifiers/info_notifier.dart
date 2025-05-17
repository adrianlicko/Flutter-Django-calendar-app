import 'package:flutter/material.dart';
import 'package:frontend/components/notifiers/notifier.dart';
import 'package:frontend/theme/app_colors.dart';

class InfoNotifier {
  static void show({
    required BuildContext context,
    required String message,
    String? trailingButtonText,
    Function()? onPressed,
  }) {
    final button = trailingButtonText != null && onPressed != null
        ? TextButton(
            onPressed: onPressed,
            child: Text(trailingButtonText),
          )
        : null;

    Notifier.show(
      context: context,
      message: message,
      notifierColor: AppColors.NOTIFIER_INFO,
      trailingButton: button,
    );
  }
}
