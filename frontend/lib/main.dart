import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/screens/loading_screen.dart';
import 'package:frontend/services/user_data_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthProvider authProvider;
  late GoRouter router;
  UserDataModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _tryAutoLogin();
    router = createRouter(authProvider);
  }

  Future<void> _tryAutoLogin() async {
    final success = await authProvider.tryAutoLogin();
    setState(() {
      isLoading = false;
    });

    if (success) {
      user = authProvider.user!;
      locator<UserDataService>().trySetPreferredPreferences(context, userData: user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(home: LoadingScreen());
    }
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      locale: localeProvider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: themeProvider.themeData,
    );
  }
}
