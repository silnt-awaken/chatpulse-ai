import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/screens.dart';

class RouterRepository {
  late final GoRouter _router;

  GoRouter get router => _router;

  RouterRepository() {
    _router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return const ContentScreen();
            },
          ),
          GoRoute(
            path: '/authentication',
            builder: (BuildContext context, GoRouterState state) {
              return AuthenticationScreen();
            },
          ),
          GoRoute(
            path: '/chatSessions',
            builder: (BuildContext context, GoRouterState state) {
              return const ChatSessionsScreen();
            },
          ),
          GoRoute(
            path: '/splash',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(
                backgroundColor: Color(0xFFd5d5e5),
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
        redirect: (context, state) async {
          // if (state.location == '/') {
          //   final hasStoredApiKey = await context
          //       .read<OpenAIFirebaseRepository>()
          //       .validateApiKey(null);

          //   if (hasStoredApiKey) {
          //     return null;
          //   } else {
          //     return '/authentication';
          //   }
          // }
          return null;
        });
  }
}
