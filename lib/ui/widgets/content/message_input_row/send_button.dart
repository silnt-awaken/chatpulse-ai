import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendButton extends StatefulWidget {
  final ScrollController scrollController;
  final String? sessionId;
  final TextEditingController textEditingController;
  final bool isDarkMode;

  const SendButton({
    Key? key,
    required this.scrollController,
    this.sessionId,
    required this.textEditingController,
    required this.isDarkMode,
  }) : super(key: key);

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
    return BlocSelector<ContentBloc, ContentState, ResponseStatus>(
      selector: (state) {
        return state.responseStatus;
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (state == ResponseStatus.waiting) return;
            if (widget.textEditingController.text.trim().isEmpty) return;
            widget.scrollController.animateTo(
              widget.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            FocusManager.instance.primaryFocus?.unfocus();

            context.read<ContentBloc>().add(ContentSendTextEvent(
                text: BlocProvider.of<ContentBloc>(context)
                    .state
                    .inputText
                    .trim()));
            widget.textEditingController.clear();
            context
                .read<ContentBloc>()
                .add(const ContentInputTextChangedEvent(text: ''));
          },
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          child: AnimatedContainer(
            height: 40,
            duration: const Duration(milliseconds: 300),
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
      },
    );
  }
}
