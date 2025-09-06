import 'package:flutter/material.dart';

class Notifier {
  static void show({
    required BuildContext context,
    required String message,
    required Color notifierColor,
    bool showOnTop = true,
    String? trailingButtonText,
    Function()? onPressed,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    void closeNotification() {
      entry.remove();
    }

    final onTop = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: 0,
          width: MediaQuery.of(ctx).size.width,
          child: _Slide(
            message: message,
            onClose: closeNotification,
            backgroundColor: notifierColor,
            trailingButtonText: trailingButtonText,
            onPressed: onPressed,
            slideFromTop: true,
          ),
        );
      },
    );
    final onBottom = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          bottom: 0,
          width: MediaQuery.of(ctx).size.width,
          child: _Slide(
            message: message,
            onClose: closeNotification,
            backgroundColor: notifierColor,
            trailingButtonText: trailingButtonText,
            onPressed: onPressed,
            slideFromTop: false,
          ),
        );
      },
    );

    entry = showOnTop ? onTop : onBottom;
    overlay.insert(entry);
  }
}

class _Slide extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final Color backgroundColor;
  final String? trailingButtonText;
  final Function()? onPressed;
  final bool slideFromTop;

  const _Slide({
    required this.message,
    required this.onClose,
    required this.backgroundColor,
    this.trailingButtonText,
    this.onPressed,
    required this.slideFromTop,
  });

  @override
  State<_Slide> createState() => _SlideState();
}

class _SlideState extends State<_Slide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = widget.slideFromTop
        ? Tween(begin: const Offset(0, -1), end: Offset.zero).animate(_controller)
        : Tween(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    Future.delayed(const Duration(seconds: 4), _close);
  }

  void _close() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.trailingButtonText != null && widget.onPressed != null
        ? TextButton(
            onPressed: () {
              widget.onPressed!.call();
              _close();
            },
            child: Text(widget.trailingButtonText!),
          )
        : null;
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
              child: button == null
                  ? Text(widget.message, style: const TextStyle(color: Colors.white))
                  : Row(
                      children: [
                        Expanded(child: Text(widget.message, style: const TextStyle(color: Colors.white))),
                        button,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
