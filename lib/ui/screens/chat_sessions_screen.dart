import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:chatpulse_ai/repositories/open_ai_firebase_repository.dart';
import 'package:chatpulse_ai/shaders/flowers_shader.dart';
import 'package:chatpulse_ai/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/widgets.dart';

class ChatSessionsScreen extends StatelessWidget {
  const ChatSessionsScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ContentBloc, ContentState, bool>(
      selector: (state) {
        return state.isDarkMode;
      },
      builder: (context, isDarkMode) {
        return CustomPaint(
          painter:
              DetailedFlowerPainter(screenSize: MediaQuery.of(context).size),
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 60,
              centerTitle: true,
              leading: BackButton(
                onPressed: () => context.go('/'),
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: AppText('Chat Sessions',
                  color: isDarkMode ? Colors.white : Colors.black),
              actions: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: AppText(
                      'edit',
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
              backgroundColor: isDarkMode ? darkPrimaryColor : accentColor,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
            ),
            backgroundColor: isDarkMode ? darkPrimaryColor : primaryColor,
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: context
                  .read<OpenAIFirebaseRepository>()
                  .getChatSessionsListFromStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: AppText('No chat sessions found.',
                        color: isDarkMode ? Colors.white : Colors.black),
                  );
                }

                final chatSessions = snapshot.data!;
                return ListView.separated(
                  itemCount: chatSessions.length,
                  itemBuilder: (context, index) {
                    final chatSession = chatSessions[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            chatSession['summary'].replaceAll('"', ''),
                            color: isDarkMode ? Colors.white : Colors.black,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                              '# of Messages: ${chatSession['messages'].length.toString()}',
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14)
                        ],
                      ),
                      onTap: () {
                        context.read<ContentBloc>().add(
                            ContentChangeSessionsEvent(
                                sessionId: chatSession['sessionId']));
                        context.go('/');
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.black38,
                    height: 1,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
