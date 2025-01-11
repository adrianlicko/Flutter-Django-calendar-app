import 'package:flutter/material.dart';

class ErrorNotifier {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: 0,
          width: MediaQuery.of(ctx).size.width,
          child: _SlideFromTop(message: message, onClose: () {}),
        );
      },
    );
    overlay.insert(entry);
  }
}

class _SlideFromTop extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  const _SlideFromTop({required this.message, required this.onClose});

  @override
  State<_SlideFromTop> createState() => _SlideFromTopState();
}

class _SlideFromTopState extends State<_SlideFromTop> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween(begin: const Offset(0, -1), end: Offset.zero).animate(_controller);
    _controller.forward();
    Future.delayed(const Duration(seconds: 4), _close);
  }

  void _close() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Material(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: const Color.fromRGBO(162, 29, 19, 1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.message, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
