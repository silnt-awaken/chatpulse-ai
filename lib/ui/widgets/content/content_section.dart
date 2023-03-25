import 'package:chatpulse_ai/ui/widgets/content/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/content/content_bloc.dart';
import '../../../models/message.dart';

class ContentSection extends StatelessWidget {
  ContentSection({super.key, required this.scrollController});

  final ScrollController scrollController;

  int messageCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocSelector<ContentBloc, ContentState, List<Message>>(
          selector: (state) {
            return state.history;
          },
          builder: (context, history) {
            return Column(children: [
              const SizedBox(height: 16),
              ...history
                  .map(
                    (message) => MessageBubble(
                      message: message.text,
                      timestamp: '',
                      isSender: history.indexOf(message) % 2 == 0,
                      index: history.indexOf(message),
                      scrollController: scrollController,
                    ),
                  )
                  .toList(),
              const SizedBox(height: 100),
            ]);
          },
        ));
  }
}
