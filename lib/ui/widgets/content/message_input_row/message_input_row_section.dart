import 'package:flutter/material.dart';

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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              const AttachmentButton(),
              const SizedBox(width: 10),
              Expanded(
                  child: CustomInputTextField(
                scrollController: widget.scrollController,
                sessionId: widget.sessionId,
                textEditingController: _textEditingController,
              )),
              const SizedBox(width: 10),
              SendButton(
                  scrollController: widget.scrollController,
                  sessionId: widget.sessionId,
                  textEditingController: _textEditingController),
              const SizedBox(width: 10),
              const MicButton(),
            ],
          ),
        ),
      ),
    );
  }
}
