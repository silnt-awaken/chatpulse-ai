import 'package:flutter/material.dart';

import '../../widgets.dart';

class MicButton extends StatefulWidget {
  const MicButton({super.key});

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AppText(
              'Voice recording coming soon!',
              color: Colors.white,
            ),
          ),
        );
        setState(() {
          isPressed = !isPressed;
        });
      },
      child: AnimatedContainer(
        height: 40,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE0E5EC),
          boxShadow: isPressed
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
        child: Center(
            child: AnimatedOpacity(
          opacity: isPressed ? 1 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.mic,
              color: Colors.red,
            ),
          ),
        )),
      ),
    );
  }
}
