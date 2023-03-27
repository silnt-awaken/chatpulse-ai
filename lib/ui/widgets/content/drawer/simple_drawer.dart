import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:chatpulse_ai/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets.dart';

class SimpleDrawer extends StatelessWidget {
  const SimpleDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocSelector<ContentBloc, ContentState, bool>(
        selector: (state) {
          return state.isDarkMode;
        },
        builder: (context, isDarkMode) {
          return Container(
            color: isDarkMode ? darkPrimaryColor : accentColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDarkMode ? darkAccentColor : accentColorShade,
                  ),
                  child: const AppText(
                    'Menu',
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.chat_bubble_outline,
                      color: isDarkMode ? Colors.white : Colors.black),
                  minLeadingWidth: 0,
                  title: AppText(
                    'New Chat',
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    context
                        .read<ContentBloc>()
                        .add(ContentStartNewSessionEvent());
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
                        leading: Icon(Icons.chat_outlined,
                            color: isDarkMode ? Colors.white : Colors.black),
                        minLeadingWidth: 0,
                        title: AppText(
                          'Previous Chats',
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        onTap: () {
                          context.read<ContentBloc>().add(
                              const ContentInputTextChangedEvent(text: ''));
                          context.go('/chatSessions');
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout,
                      color: isDarkMode ? Colors.white : Colors.black),
                  minLeadingWidth: 0,
                  title: AppText(
                    'Logout',
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    context
                        .read<ContentBloc>()
                        .add(const ContentInputTextChangedEvent(text: ''));
                    context.read<ContentBloc>().add(ContentLogoutEvent());
                  },
                ),
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode ? Colors.yellow : Colors.black,
                  ),
                  minLeadingWidth: 0,
                  title: AppText(
                    isDarkMode ? 'Light Mode' : 'Dark Mode',
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    context
                        .read<ContentBloc>()
                        .add(const ContentInputTextChangedEvent(text: ''));
                    context
                        .read<ContentBloc>()
                        .add(ContentToggleDarkModeEvent());
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
