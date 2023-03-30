import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/content/content_bloc.dart';
import 'message_input_row.dart';

class MessageInputRowSection extends StatefulWidget {
  final ScrollController scrollController;
  final String? sessionId;
  const MessageInputRowSection(
      {super.key, required this.scrollController, this.sessionId});

  @override
  State<MessageInputRowSection> createState() => _MessageInputRowSectionState();
}

class _MessageInputRowSectionState extends State<MessageInputRowSection> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentBloc, ContentState>(
      listener: (context, state) {
        if (state.inputText.isEmpty) {
          _textEditingController.clear();
        }

        if (state.responseStatus == ResponseStatus.generating &&
            !state.hasDraggedWhileGenerating &&
            !state.generationFinished) {
          widget.scrollController.animateTo(
            widget.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
      child: BlocSelector<ContentBloc, ContentState, bool>(
        selector: (state) {
          return state.isDarkMode;
        },
        builder: (context, isDarkMode) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    AttachmentButton(
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: CustomInputTextField(
                      scrollController: widget.scrollController,
                      sessionId: widget.sessionId,
                      textEditingController: _textEditingController,
                      isDarkMode: isDarkMode,
                    )),
                    const SizedBox(width: 10),
                    SendButton(
                      scrollController: widget.scrollController,
                      sessionId: widget.sessionId,
                      textEditingController: _textEditingController,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(width: 10),
                    MicButton(
                      isDarkMode: isDarkMode,
                      textEditingController: _textEditingController,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
