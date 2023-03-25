import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendButton extends StatefulWidget {
  final ScrollController scrollController;
  final String? sessionId;
  final TextEditingController textEditingController;

  const SendButton(
      {Key? key,
      required this.scrollController,
      this.sessionId,
      required this.textEditingController})
      : super(key: key);

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
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
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        FocusManager.instance.primaryFocus?.unfocus();

        context.read<ContentBloc>().add(ContentSendTextEvent(
            text: BlocProvider.of<ContentBloc>(context).state.inputText));
        widget.textEditingController.clear();
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
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
        child: const Center(
          child: AnimatedOpacity(
            opacity: 1,
            duration: Duration(milliseconds: 300),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.send,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
