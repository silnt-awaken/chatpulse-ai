import 'package:flutter/material.dart';

import '../../widgets.dart';

class AttachmentButton extends StatefulWidget {
  final bool isDarkMode;
  const AttachmentButton({Key? key, required this.isDarkMode})
      : super(key: key);

  @override
  State<AttachmentButton> createState() => _AttachmentButtonState();
}

class _AttachmentButtonState extends State<AttachmentButton> {
  bool isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: AppText(
            'Image attachment coming soon!',
            color: Colors.white,
          )),
        );
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE0E5EC),
          boxShadow: widget.isDarkMode
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                  ),
                ]
              : isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(-3, -3),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(3, 3),
                        blurRadius: 8,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(-6, -6),
                        blurRadius: 16,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(6, 6),
                        blurRadius: 16,
                      ),
                    ],
        ),
        child: const Center(
          child: AnimatedOpacity(
            opacity: 1,
            duration: Duration(milliseconds: 100),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.image,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
