import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: obscureText,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.areaCannotBeEmpty;
                }
                if (widget.validator != null) {
                  return widget.validator!(value);
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: widget.labelText,
                floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                ),
              )),
          if (widget.obscureText)
            Positioned(
              top: 5,
              right: 2,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  )),
            )
        ],
      ),
    );
  }
}
