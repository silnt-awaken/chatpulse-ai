import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets.dart';

class SimpleDrawer extends StatelessWidget {
  const SimpleDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFd5d5e5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFc5c5d5),
              ),
              child: AppText(
                'Menu',
                fontSize: 24,
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.chat_bubble_outline, color: Colors.black),
              title: const AppText('New Chat'),
              onTap: () {
                context.read<ContentBloc>().add(ContentStartNewSessionEvent());
                Navigator.pop(context);
              },
            ),
            BlocSelector<ContentBloc, ContentState, String?>(
              selector: (state) {
                return state.apiKey;
              },
              builder: (context, apiKey) {
                return Visibility(
                  visible: apiKey != null,
                  child: ListTile(
                    leading: const Icon(Icons.chat, color: Colors.black),
                    title: const AppText('Previous Chats'),
                    onTap: () {
                      context.go('/chatSessions');
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const AppText('Logout'),
              onTap: () {
                context.read<ContentBloc>().add(ContentLogoutEvent());
                //context.go('/authentication');
              },
            ),
          ],
        ),
      ),
    );
  }
}
