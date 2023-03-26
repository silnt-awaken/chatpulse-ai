import 'package:flutter/material.dart';

import 'message_input_row.dart';

class MessageInputRowSection extends StatelessWidget {
  final ScrollController scrollController;
  final String? sessionId;
  MessageInputRowSection(
      {super.key, required this.scrollController, this.sessionId});

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
                scrollController: scrollController,
                sessionId: sessionId,
                textEditingController: _textEditingController,
              )),
              const SizedBox(width: 10),
              SendButton(
                  scrollController: scrollController,
                  sessionId: sessionId,
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
