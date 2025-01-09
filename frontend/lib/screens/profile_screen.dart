import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/services/user_preferences_service.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userPreferencesService = locator<UserPreferencesService>();
  late UserDataModel _userData;

  @override
  void initState() {
    super.initState();
    _userData = Provider.of<AuthProvider>(context, listen: false).user!;
  }

  Widget _buildOption(
      {required String title, required bool isEnabled, required void Function() onTap, bool isNested = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isNested) const SizedBox(width: 16.0),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
        Transform.scale(
          scale: 1.3,
          child: Checkbox(
            value: isEnabled,
            onChanged: (bool? value) {
              onTap();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditOption({required String title, required void Function() onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
        Transform.scale(
            scale: 1.3,
            child: IconButton(
                onPressed: onTap, icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColorDark))),
      ],
    );
  }

  Widget _buildDropdownOption({required String title, required Widget dropdownButton}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
        dropdownButton,
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> options}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: options,
          ),
        ),
        Positioned(
            top: 5,
            left: 25,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Text(title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor)),
            )),
      ],
    );
  }

  Widget _buildSections() {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        _buildSection(title: AppLocalizations.of(context)!.profile, options: [
          _buildEditOption(title: AppLocalizations.of(context)!.changeEmail, onTap: () {}),
          _buildEditOption(title: AppLocalizations.of(context)!.changePassword, onTap: () {})
        ]),
        const SizedBox(height: 16.0),
        _buildSection(
            title: "${AppLocalizations.of(context)!.calendar}/${AppLocalizations.of(context)!.todoTasks}",
            options: [
              _buildOption(title: AppLocalizations.of(context)!.showTodoTasksInCalendar, isEnabled: true, onTap: () {}),
              _buildOption(
                  title: AppLocalizations.of(context)!.removeTodoFromCalendarWhenCompleted,
                  isEnabled: true,
                  onTap: () {},
                  isNested: true)
            ]),
        const SizedBox(height: 16.0),
        _buildSection(title: AppLocalizations.of(context)!.applicationSettings, options: [
          _buildDropdownOption(
            title: AppLocalizations.of(context)!.changeLanguage,
            dropdownButton: DropdownButton<Locale>(
              dropdownColor: themeProvider.currentTheme.secondaryColor,
              value: localeProvider.locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  localeProvider.setLocale(newLocale);
                  _userPreferencesService.updatePreferences(UserPreferencesModel(
                    locale: newLocale,
                    theme: themeProvider.currentTheme,
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
                          .copyWith(color: Provider.of<ThemeProvider>(context).currentTheme.textColor)),
                );
              }).toList(),
            ),
          ),
          _buildDropdownOption(
            title: AppLocalizations.of(context)!.changeTheme,
            dropdownButton: DropdownButton<AllAppColors>(
              dropdownColor: themeProvider.currentTheme.secondaryColor,
              value: themeProvider.currentTheme,
              onChanged: (AllAppColors? newTheme) {
                if (newTheme != null) {
                  themeProvider.setTheme(newTheme);
                  
                  _userPreferencesService.updatePreferences(UserPreferencesModel(
                    locale: localeProvider.locale,
                    theme: newTheme,
                    showTodosInCalendar: true,
                    removeTodoFromCalendarWhenCompleted: true,
                  ));
                }
              },
              items: AllAppColors.values.map((AllAppColors theme) {
                return DropdownMenuItem(
                  value: theme,
                  child: Text(theme.toString().split('.').last,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Provider.of<ThemeProvider>(context).currentTheme.textColor)),
                );
              }).toList(),
            ),
          ),
        ])
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        const CircleAvatar(
          radius: 50.0,
          child: Icon(Icons.person, size: 50.0),
        ),
        const SizedBox(height: 16.0),
        Text("${_userData.firstName} ${_userData.lastName}",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(_userData.email, style: Theme.of(context).textTheme.bodyMedium)]),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        actions: [
          IconButton(
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
              icon: const Icon(Icons.logout)),
        ],
        body: Column(
          children: [
            _buildProfileHeader(),
            _buildSections(),
          ],
        ));
  }
}
