import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? leading;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leading != null ? Row(children: leading!) : null,
        title: title != null ? Text(title!) : null,
        actions: actions,
      ),
      body: body,
    );
  }
}
