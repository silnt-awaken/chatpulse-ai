import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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

    return BlocListener<ContentBloc, ContentState>(
      listener: (context, state) {
        if (state.responseStatus == ResponseStatus.success) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            context.read<ContentBloc>().add(
                const ContentChangeResponseStatusEvent(
                    responseStatus: ResponseStatus.idle));
          });
        }
      },
      child: Column(
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
                      if (!isSender) {
                        return GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: message));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                              ),
                            );
                          },
                          child: MarkdownBody(
                            data: message,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.nunitoSans(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              //img: ,
                              code: GoogleFonts.spaceMono(
                                color: Colors.white,
                                backgroundColor: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              codeblockPadding: const EdgeInsets.all(8),
                            ),
                          ),
                        );
                      } else {
                        return AppText(
                          message,
                          selectable: true,
                        );
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
                  child: BlocSelector<ContentBloc, ContentState, bool>(
                    selector: (state) {
                      return state.isDarkMode;
                    },
                    builder: (context, isDarkMode) {
                      return SpinKitThreeBounce(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        size: 20,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
