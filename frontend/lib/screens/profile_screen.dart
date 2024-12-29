import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:frontend/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                onPressed: onTap,
                icon: Icon(Icons.edit_outlined, color: AllAppColors.lightBlueColorScheme.primaryAccent))),
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
            border: Border.all(
                color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor, width: 2.0),
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
              color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).scaffoldBackgroundColor,
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor)),
            )),
      ],
    );
  }

  Widget _buildSections() {
    return Column(
      children: [
        _buildSection(title: "Profile", options: [
          _buildEditOption(title: "Change email", onTap: () {}),
          _buildEditOption(title: "Change password", onTap: () {})
        ]),
        const SizedBox(height: 16.0),
        _buildSection(title: "Calendar/Todo", options: [
          _buildOption(title: "Show todo tasks in calendar", isEnabled: true, onTap: () {}),
          _buildOption(
              title: "Remove todo tasks from calendar when completed", isEnabled: true, onTap: () {}, isNested: true)
        ]),
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
        Text("Name Surname", style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("nejaky email", style: Theme.of(context).textTheme.bodyMedium)]),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Column(
      children: [
        _buildProfileHeader(),
        _buildSections(),
      ],
    ));
  }
}
