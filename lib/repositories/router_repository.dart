import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/screens.dart';

class RouterRepository {
  late final GoRouter _router;

  GoRouter get router => _router;

  RouterRepository() {
    _router = GoRouter(
        initialLocation: '/authentication',
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
        ],
        redirect: (context, state) {
          return null;
        });
  }
}
