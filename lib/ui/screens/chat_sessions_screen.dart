import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:chatpulse_ai/repositories/open_ai_firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../widgets/widgets.dart';

class ChatSessionsScreen extends StatelessWidget {
  const ChatSessionsScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        centerTitle: true,
        leading: BackButton(
          onPressed: () => context.go('/'),
        ),
        title: const AppText('Chat Sessions'),
        actions: const [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: AppText(
                'edit',
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
        backgroundColor: const Color(0xFFc5c5d5),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFd5d5e5).withOpacity(0.9),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: context.read<OpenAIFirebaseRepository>().getChatSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No chat sessions found.'),
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
                    ),
                    const SizedBox(height: 8),
                    AppText(
                        '# of Messages: ${chatSession['messages'].length.toString()}',
                        fontWeight: FontWeight.w600,
                        fontSize: 14)
                  ],
                ),
                onTap: () {
                  context.read<ContentBloc>().add(ContentChangeSessionsEvent(
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
    );
  }
}
