import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/components/custom_text_field.dart';
import 'package:frontend/components/error_notifier.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/services/user_data_service.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLoginScreen = true;
  final UserDataService _userPreferencesService = locator<UserDataService>();
  bool isButtonLoading = false;
  late LocaleProvider localeProvider;
  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  TextEditingController registerFirstNameController = TextEditingController();
  TextEditingController registerLastNameController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  }

  Widget _buildSubmitButton({required String label, required void Function() onPressed}) {
    return SizedBox(
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
          onPressed: isButtonLoading ? () {} : onPressed,
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
          child: isButtonLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(label, style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white))),
    );
  }

  Widget _buildSwitchAuthButton({required String label, required void Function() onPressed}) {
    return TextButton(
        onPressed: onPressed,
        child: Text(label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColorDark)));
  }

  Widget _buildRegisterWidget() {
    return Column(
      children: [
        Form(
            key: registerFormKey,
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                      child: CustomTextField(
                          controller: registerFirstNameController,
                          keyboardType: TextInputType.name,
                          labelText: AppLocalizations.of(context)!.firstName)),
                  Expanded(
                    child: CustomTextField(
                        controller: registerLastNameController,
                        keyboardType: TextInputType.name,
                        labelText: AppLocalizations.of(context)!.lastName),
                  )
                ],
              ),
              CustomTextField(
                controller: registerEmailController,
                labelText: AppLocalizations.of(context)!.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (!value!.contains('@') || !value.contains('.')) {
                    return AppLocalizations.of(context)!.incorrectEmailFormat;
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: registerPasswordController,
                labelText: AppLocalizations.of(context)!.password,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: (value) {
                  if (value!.length < 6) {
                    return AppLocalizations.of(context)!.passwordMustBeLonger;
                  }
                  return null;
                },
              ),
            ])),
        _buildSubmitButton(
            label: AppLocalizations.of(context)!.register,
            onPressed: () async {
              if (registerFormKey.currentState!.validate()) {
                setState(() {
                  isButtonLoading = true;
                });
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                bool success = await authProvider.register(
                    email: registerEmailController.text,
                    password: registerPasswordController.text,
                    firstName: registerFirstNameController.text,
                    lastName: registerLastNameController.text);
                if (!success) {
                  ErrorNotifier.show(context, AppLocalizations.of(context)!.failedToRegister);
                  setState(() {
                    isButtonLoading = false;
                  });
                  return;
                }
                if (authProvider.isAuthenticated && authProvider.user != null) {
                  final userData = Provider.of<AuthProvider>(context, listen: false).user;
                  locator<UserDataService>().trySetPreferredPreferences(context, userData: userData!);
                }
                setState(() {
                  isButtonLoading = false;
                });
              }
            }),
        _buildSwitchAuthButton(
            label: AppLocalizations.of(context)!.alreadyHaveAccount,
            onPressed: () {
              setState(() {
                _showLoginScreen = true;
              });
            })
      ],
    );
  }

  Widget _buildLoginWidget() {
    return Column(
      children: [
        Form(
            key: loginFormKey,
            child: Column(children: [
              CustomTextField(
                controller: loginEmailController,
                labelText: AppLocalizations.of(context)!.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (!value!.contains('@') || !value.contains('.')) {
                    return AppLocalizations.of(context)!.incorrectEmailFormat;
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: loginPasswordController,
                labelText: AppLocalizations.of(context)!.password,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: (value) {
                  if (value!.length < 6) {
                    return AppLocalizations.of(context)!.passwordMustBeLonger;
                  }
                  return null;
                },
              ),
            ])),
        _buildSubmitButton(
            label: AppLocalizations.of(context)!.login,
            onPressed: () async {
              if (loginFormKey.currentState!.validate()) {
                setState(() {
                  isButtonLoading = true;
                });
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                bool success =
                    await authProvider.login(email: loginEmailController.text, password: loginPasswordController.text);
                if (!success) {
                  ErrorNotifier.show(context, AppLocalizations.of(context)!.failedToLogin);
                  setState(() {
                    isButtonLoading = false;
                  });
                  return;
                }
                if (authProvider.isAuthenticated && authProvider.user != null) {
                  final userData = Provider.of<AuthProvider>(context, listen: false).user;
                  locator<UserDataService>().trySetPreferredPreferences(context, userData: userData!);
                }
              }
            }),
        _buildSwitchAuthButton(
            label: AppLocalizations.of(context)!.dontHaveAccountYet,
            onPressed: () {
              setState(() {
                _showLoginScreen = false;
              });
            })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _showLoginScreen ? _buildLoginWidget() : _buildRegisterWidget(),
            DropdownButton<Locale>(
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              value: localeProvider.locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  localeProvider.setLocale(newLocale);
                  _userPreferencesService.updatePreferences(context, UserPreferencesModel(
                    locale: newLocale,
                    theme: Provider.of<ThemeProvider>(context, listen: false).currentTheme,
                    showTodosInCalendar: true,
                    removeTodoFromCalendarWhenCompleted: true,
                  ));
                }
              },
              items: L10n.all.map((Locale locale) {
                final flag = locale.languageCode == 'en' ? '🇺🇸' : '🇸🇰';
                return DropdownMenuItem(
                  value: locale,
                  child: Text(flag,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Theme.of(context).textTheme.bodyMedium!.color)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ));
  }
}
