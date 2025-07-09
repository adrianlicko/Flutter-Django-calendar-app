import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/custom_text_field.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/user_data_model.dart';
import 'package:frontend/models/user_preferences_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/services/user_data_service.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:provider/provider.dart';
import 'package:frontend/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _userDataService = locator<UserDataService>();
  late UserDataModel _userData;
  bool _isNameTextFieldEnabled = false;
  bool _isEmailTextFieldEnabled = false;
  bool _isPasswordTextFieldEnabled = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _nameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordKey = GlobalKey<FormState>();
  bool isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    _userData = Provider.of<AuthProvider>(context, listen: false).user!;
  }

  Widget _buildOption(
      {required String title,
      required bool isEnabled,
      required void Function(bool? value) onTap,
      bool isNested = false,
      Color? optionColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isNested) const SizedBox(width: 16.0),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
        Transform.scale(
          scale: 1.3,
          child: Checkbox(
            fillColor: WidgetStateProperty.all(optionColor),
            value: isEnabled,
            onChanged: (bool? value) {
              onTap(value);
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

  Widget _buildProfileSection() {
    return Column(
      children: [
        _buildSection(title: AppLocalizations.of(context)!.profile, options: [
          _buildEditOption(
              title: AppLocalizations.of(context)!.changeName,
              onTap: () {
                setState(() {
                  _isNameTextFieldEnabled = !_isNameTextFieldEnabled;
                });
              }),
          if (_isNameTextFieldEnabled)
            Form(
              key: _isNameTextFieldEnabled ? _nameKey : null,
              child: Column(children: [
                CustomTextField(controller: _firstNameController, labelText: AppLocalizations.of(context)!.firstName),
                CustomTextField(controller: _lastNameController, labelText: AppLocalizations.of(context)!.lastName),
              ]),
            ),
          _buildEditOption(
              title: AppLocalizations.of(context)!.changeEmail,
              onTap: () {
                setState(() {
                  _isEmailTextFieldEnabled = !_isEmailTextFieldEnabled;
                });
              }),
          if (_isEmailTextFieldEnabled)
            Form(
              key: _isEmailTextFieldEnabled ? _emailKey : null,
              child: CustomTextField(controller: _emailController, labelText: AppLocalizations.of(context)!.email),
            ),
          _buildEditOption(
              title: AppLocalizations.of(context)!.changePassword,
              onTap: () {
                setState(() {
                  _isPasswordTextFieldEnabled = !_isPasswordTextFieldEnabled;
                });
              }),
          if (_isPasswordTextFieldEnabled)
            Form(
              key: _isPasswordTextFieldEnabled ? _passwordKey : null,
              child: CustomTextField(
                  controller: _passwordController,
                  obscureText: true,
                  labelText: AppLocalizations.of(context)!.password),
            ),
          if (_isNameTextFieldEnabled || _isEmailTextFieldEnabled || _isPasswordTextFieldEnabled)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 35.0,
                width: 110.0,
                child: ElevatedButton(
                    onPressed: isButtonLoading
                        ? () {}
                        : () async {
                            if (_isNameTextFieldEnabled && _nameKey.currentState!.validate() ||
                                _isEmailTextFieldEnabled && _emailKey.currentState!.validate() ||
                                _isPasswordTextFieldEnabled && _passwordKey.currentState!.validate()) {
                              setState(() {
                                isButtonLoading = true;
                              });
                              final response = await _userDataService.updateUserData(
                                  context,
                                  UserDataModel(
                                      id: _userData.id,
                                      email: _isEmailTextFieldEnabled ? _emailController.text : _userData.email,
                                      firstName:
                                          _isNameTextFieldEnabled ? _firstNameController.text : _userData.firstName,
                                      lastName: _isNameTextFieldEnabled ? _lastNameController.text : _userData.lastName,
                                      password:
                                          _isPasswordTextFieldEnabled ? _passwordController.text : _userData.password,
                                      preferences: _userData.preferences));
                              _userData = response!;
                              setState(() {
                                isButtonLoading = false;
                                _firstNameController.text = '';
                                _lastNameController.text = '';
                                _emailController.text = '';
                                _isNameTextFieldEnabled = false;
                                _emailController.text = '';
                                _isEmailTextFieldEnabled = false;
                                _passwordController.text = '';
                                _isPasswordTextFieldEnabled = false;
                              });
                            }
                          },
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
                    child: isButtonLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(AppLocalizations.of(context)!.save,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white))),
              ),
            )
        ]),
      ],
    );
  }

  Widget _buildSections() {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        _buildProfileSection(),
        const SizedBox(height: 16.0),
        _buildSection(
            title: "${AppLocalizations.of(context)!.calendar}/${AppLocalizations.of(context)!.todoTasks}",
            options: [
              _buildOption(
                  title: AppLocalizations.of(context)!.showTodoTasksInCalendar,
                  isEnabled: _userData.preferences.showTodosInCalendar,
                  onTap: (value) async {
                    final response = await _userDataService.updatePreferences(
                        context,
                        UserPreferencesModel(
                          locale: _userData.preferences.locale,
                          theme: _userData.preferences.theme,
                          showTodosInCalendar: value!,
                          removeTodoFromCalendarWhenCompleted:
                              _userData.preferences.removeTodoFromCalendarWhenCompleted,
                        ));
                    _userData.preferences.setShowTodosInCalendar(response!.showTodosInCalendar);
                    setState(() {});
                  }),
              _buildOption(
                  title: AppLocalizations.of(context)!.removeTodoFromCalendarWhenCompleted,
                  isEnabled: _userData.preferences.removeTodoFromCalendarWhenCompleted,
                  optionColor: _userData.preferences.showTodosInCalendar ? null : Colors.grey[700],
                  onTap: (value) async {
                    if (!_userData.preferences.showTodosInCalendar) return;
                    final response = await _userDataService.updatePreferences(
                        context,
                        UserPreferencesModel(
                          locale: _userData.preferences.locale,
                          theme: _userData.preferences.theme,
                          showTodosInCalendar: _userData.preferences.showTodosInCalendar,
                          removeTodoFromCalendarWhenCompleted: value!,
                        ));
                    _userData.preferences
                        .setRemoveTodoFromCalendarWhenCompleted(response!.removeTodoFromCalendarWhenCompleted);
                    setState(() {});
                  },
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
                  _userData.preferences.setLocale(newLocale);
                  _userDataService.updatePreferences(
                      context,
                      UserPreferencesModel(
                        locale: newLocale,
                        theme: _userData.preferences.theme,
                        showTodosInCalendar: _userData.preferences.showTodosInCalendar,
                        removeTodoFromCalendarWhenCompleted: _userData.preferences.removeTodoFromCalendarWhenCompleted,
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
                  _userData.preferences.setTheme(newTheme);
                  _userDataService.updatePreferences(
                      context,
                      UserPreferencesModel(
                        locale: _userData.preferences.locale,
                        theme: newTheme,
                        showTodosInCalendar: _userData.preferences.showTodosInCalendar,
                        removeTodoFromCalendarWhenCompleted: _userData.preferences.removeTodoFromCalendarWhenCompleted,
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildSections(),
              const SizedBox(height: 24.0),
            ],
          ),
        ));
  }
}
