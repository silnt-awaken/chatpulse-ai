import 'package:chatpulse_ai/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../blocs/content/content_bloc.dart';

class ContentSection extends StatefulWidget {
  const ContentSection({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  int messageCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocConsumer<ContentBloc, ContentState>(
          listener: (context, state) {
            if (state.responseStatus == ResponseStatus.success) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.scrollController.animateTo(
                  widget.scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
              });
            }
          },
          builder: (context, state) {
            return Column(children: [
              const SizedBox(height: 16),
              ...state.history
                  .map(
                    (message) => MessageBubble(
                      message: message.text,
                      timestamp: '',
                      isSender: state.history.indexOf(message) % 2 == 0,
                      index: state.history.indexOf(message),
                      scrollController: widget.scrollController,
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
                                    context
                                        .read<ContentBloc>()
                                        .add(ContentStartNewSessionEvent());
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
          },
        ));
  }
}
