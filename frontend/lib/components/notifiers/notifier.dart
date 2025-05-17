import 'package:flutter/material.dart';

class Notifier {
  static void show({
    required BuildContext context,
    required String message,
    required Color notifierColor,
    bool showOnTop = true,
    Widget? trailingButton,
  }) {
    final overlay = Overlay.of(context);
    final onTop = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: 0,
          width: MediaQuery.of(ctx).size.width,
          child: _SlideFromTop(
            message: message,
            onClose: () {},
            backgroundColor: notifierColor,
            trailingButton: trailingButton,
          ),
        );
      },
    );
    final onBottom = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          bottom: 0,
          width: MediaQuery.of(ctx).size.width,
          child: _SlideFromTop(
            message: message,
            onClose: () {},
            backgroundColor: notifierColor,
            trailingButton: trailingButton,
          ),
        );
      },
    );
    final entry = showOnTop ? onTop : onBottom;
    overlay.insert(entry);
  }
}

class _SlideFromTop extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final Color backgroundColor;
  final Widget? trailingButton;

  const _SlideFromTop({
    required this.message,
    required this.onClose,
    required this.backgroundColor,
    this.trailingButton,
  });

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
            color: widget.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.trailingButton == null
                  ? Text(widget.message, style: const TextStyle(color: Colors.white))
                  : Row(
                      children: [
                        Expanded(child: Text(widget.message, style: const TextStyle(color: Colors.white))),
                        widget.trailingButton!,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
