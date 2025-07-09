import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/l10n/app_localizations.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_off_outlined,
              color: Theme.of(context).appBarTheme.iconTheme!.color,
              size: 36.0,
            ),
            const SizedBox(height: 16.0),
            Text(AppLocalizations.of(context)!.noInternetConnection),
          ],
        ),
      ),
    );
  }
}
