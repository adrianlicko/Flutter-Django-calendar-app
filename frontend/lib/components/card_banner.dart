import 'package:flutter/material.dart';

class CardBanner extends StatelessWidget {
  final String title;
  final List<Color> gradientColors;
  final void Function() onTap;
  final Widget? icon;

  const CardBanner({
    super.key,
    required this.title,
    required this.gradientColors,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0, left: 16.0),
        child: AspectRatio(
          aspectRatio: 2 / 0.6,
          child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)), icon ?? Container()],
                ),
              )),
        ),
      ),
    );
  }
}
