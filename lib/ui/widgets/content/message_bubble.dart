import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../blocs/content/content_bloc.dart';
import '../widgets.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isSender;
  final int index;
  final ScrollController scrollController;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.timestamp,
    this.isSender = false,
    required this.index,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth =
        MediaQuery.of(context).size.width * 0.7; // 70% of the screen width

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color.fromARGB(255, 217, 221, 226),
                    boxShadow: [
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
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(
                    bottom: 2,
                    left: 1,
                    right: 1,
                  ),
                  child: BlocBuilder<ContentBloc, ContentState>(
                      builder: (context, state) {
                    if (state.history.length - 1 == index &&
                        state.responseStatus == ResponseStatus.success) {
                      return AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            message.trim(),
                            textStyle: GoogleFonts.nunitoSans(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            speed: const Duration(milliseconds: 10),
                          )
                        ],
                        isRepeatingAnimation: false,
                        onNextBeforePause: (_, __) {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );

                          context.read<ContentBloc>().add(
                              const ContentChangeResponseStatusEvent(
                                  responseStatus: ResponseStatus.idle));
                        },
                      );
                    } else {
                      return AppText(message);
                    }
                  })),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 50,
          child: BlocSelector<ContentBloc, ContentState, ResponseStatus>(
            selector: (state) {
              return state.responseStatus;
            },
            builder: (context, state) {
              return Visibility(
                visible: state == ResponseStatus.waiting &&
                    index ==
                        BlocProvider.of<ContentBloc>(context)
                                .state
                                .history
                                .length -
                            1,
                child: const SpinKitThreeBounce(
                  color: Colors.black87,
                  size: 20,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
