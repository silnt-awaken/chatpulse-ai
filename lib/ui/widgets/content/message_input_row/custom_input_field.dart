import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputTextField extends StatefulWidget {
  final ScrollController scrollController;
  final String? sessionId;
  final TextEditingController textEditingController;
  final bool isDarkMode;
  const CustomInputTextField({
    Key? key,
    required this.scrollController,
    this.sessionId,
    required this.textEditingController,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<CustomInputTextField> createState() => _CustomInputTextFieldState();
}

class _CustomInputTextFieldState extends State<CustomInputTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            widget.scrollController.animateTo(
              widget.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
                : _isFocused
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
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child:
                        BlocSelector<ContentBloc, ContentState, ResponseStatus>(
                      selector: (state) {
                        return state.responseStatus;
                      },
                      builder: (context, state) {
                        return BlocSelector<ContentBloc, ContentState,
                            ValidationState>(
                          selector: (state) {
                            return state.validationState;
                          },
                          builder: (context, apiKeyState) {
                            return TextField(
                              controller: widget.textEditingController,
                              focusNode: _focusNode,
                              maxLines: null,
                              enabled: apiKeyState == ValidationState.validated,
                              onSubmitted: (value) {
                                if (state == ResponseStatus.waiting) return;
                                if (widget.textEditingController.text
                                    .trim()
                                    .isEmpty) return;
                                widget.scrollController.animateTo(
                                  widget.scrollController.position
                                      .maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                                FocusManager.instance.primaryFocus?.unfocus();
                                context.read<ContentBloc>().add(
                                    ContentSendMessageForStreamEvent(
                                        text: value.trim()));

                                context.read<ContentBloc>().add(
                                    const ContentInputTextChangedEvent(
                                        text: ''));
                                widget.textEditingController.clear();
                              },
                              onChanged: ((value) {
                                context.read<ContentBloc>().add(
                                    ContentInputTextChangedEvent(text: value));

                                widget.textEditingController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: widget.textEditingController
                                            .text.length));
                              }),
                              style: GoogleFonts.nunitoSans(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    apiKeyState == ValidationState.validating
                                        ? 'Awaiting api key validation...'
                                        : 'Type your message here',
                                hintStyle: GoogleFonts.nunitoSans(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                              ),
                              cursorColor: Colors
                                  .transparent, // hide the cursor by making it transparent
                              showCursor: !_isFocused ||
                                  _focusNode.hasFocus &&
                                      _focusNode.hasFocus &&
                                      _focusNode.hasFocus &&
                                      _focusNode.hasFocus &&
                                      _focusNode
                                          .hasFocus, // hide the cursor if the TextField is not focused or if it is focused but there is no text
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              BlocSelector<ContentBloc, ContentState, bool>(
                selector: (state) {
                  return state.inputText.isNotEmpty;
                },
                builder: (context, state) {
                  return Visibility(
                    visible: state,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              widget.textEditingController.clear();
                              context.read<ContentBloc>().add(
                                  const ContentInputTextChangedEvent(text: ''));
                            },
                            child: Container(
                                height: 18,
                                width: 18,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.grey),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 14,
                                )),
                          ),
                        )),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
