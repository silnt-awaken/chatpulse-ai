import 'package:chatpulse_ai/repositories/open_ai_firebase_repository.dart';
import 'package:chatpulse_ai/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
            return StreamBuilder<List<Message>>(
                stream: context
                    .read<OpenAIFirebaseRepository>()
                    .getChatSessionMessagesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(children: [
                      const SizedBox(height: 16),
                      ...snapshot.data!
                          .map(
                            (message) => MessageBubble(
                              message: message.text,
                              timestamp: '',
                              isSender:
                                  snapshot.data!.indexOf(message) % 2 == 0,
                              index: snapshot.data!.indexOf(message),
                              scrollController: scrollController,
                            ),
                          )
                          .toList(),
                      BlocSelector<ContentBloc, ContentState, ResponseStatus>(
                        selector: (state) {
                          return state.responseStatus;
                        },
                        builder: (context, state) {
                          return Visibility(
                            visible: state == ResponseStatus.failed,
                            child: Container(
                                color: Colors.red.withOpacity(0.6),
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      const WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '  ',
                                      ),
                                      const TextSpan(
                                        text: 'An error occured... Start a new',
                                      ),
                                      TextSpan(
                                        text: ' chat',
                                        style: GoogleFonts.nunitoSans(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            context.read<ContentBloc>().add(
                                                ContentStartNewSessionEvent());
                                          },
                                      ),
                                      const TextSpan(
                                        text: '?',
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ]);
                  } else {
                    return const SizedBox.shrink();
                  }
                });
          },
        ));
  }
}
