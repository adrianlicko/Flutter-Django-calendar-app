import 'package:flutter/material.dart';
import 'package:frontend/components/notifiers/notifier.dart';
import 'package:frontend/theme/app_colors.dart';

class ErrorNotifier {
  static void show({
    required BuildContext context,
    required String message,
  }) {
    Notifier.show(context: context, message: message, notifierColor: AppColors.NOTIFIER_ERROR);
  }
}
