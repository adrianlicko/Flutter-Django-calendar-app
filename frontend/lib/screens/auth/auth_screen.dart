import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLoginScreen = true;

  Widget _buildTextFormField(
      {required TextEditingController controller,
      required String labelText,
      String? Function(String?)? validator,
      TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context)!.areaCannotBeEmpty;
            }
            if (validator != null) {
              return validator(value);
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: labelText,
            floatingLabelStyle: const TextStyle(color: Color.fromRGBO(0, 121, 191, 1)),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(0, 121, 191, 1), width: 2.0),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.0),
            ),
          )),
    );
  }

  Widget _buildSubmitButton({required String label, required void Function() onPressed}) {
    return SizedBox(
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white))),
    );
  }

  Widget _buildSwitchAuthButton({required String label, required void Function() onPressed}) {
    return TextButton(
        onPressed: onPressed,
        child: Text(label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColorDark)));
  }

  Widget _buildRegisterWidget() {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Column(
      children: [
        Form(
            key: formKey,
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                      child: _buildTextFormField(
                          controller: firstNameController,
                          keyboardType: TextInputType.name,
                          labelText: AppLocalizations.of(context)!.firstName)),
                  Expanded(
                    child: _buildTextFormField(
                        controller: lastNameController,
                        keyboardType: TextInputType.name,
                        labelText: AppLocalizations.of(context)!.lastName),
                  )
                ],
              ),
              _buildTextFormField(
                controller: emailController,
                labelText: AppLocalizations.of(context)!.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (!value!.contains('@') || !value.contains('.')) {
                    return AppLocalizations.of(context)!.incorrectEmailFormat;
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: passwordController,
                labelText: AppLocalizations.of(context)!.password,
                keyboardType: TextInputType.visiblePassword,
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
              if (formKey.currentState!.validate()) {
                bool success = await Provider.of<AuthProvider>(context, listen: false).register(
                    email: emailController.text,
                    password: passwordController.text,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text);
                if (success) {
                  // todo Navigate to home or show success message
                } else {
                  // todo Show error message
                }
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
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Column(
      children: [
        Form(
            key: formKey,
            child: Column(children: [
              _buildTextFormField(
                controller: emailController,
                labelText: AppLocalizations.of(context)!.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (!value!.contains('@') || !value.contains('.')) {
                    return AppLocalizations.of(context)!.incorrectEmailFormat;
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: passwordController,
                labelText: AppLocalizations.of(context)!.password,
                keyboardType: TextInputType.visiblePassword,
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
              if (formKey.currentState!.validate()) {
                bool success = await Provider.of<AuthProvider>(context, listen: false)
                    .login(email: emailController.text, password: passwordController.text);
                if (success) {
                  // todo Navigate to home
                } else {
                  // todo Show error message
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
    final localeProvider = Provider.of<LocaleProvider>(context);

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
                }
              },
              items: L10n.all.map((Locale locale) {
                final flag = locale.languageCode == 'en' ? '🇺🇸' : '🇸🇰';
                return DropdownMenuItem(
                  value: locale,
                  child: Text(flag, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ));
  }
}
