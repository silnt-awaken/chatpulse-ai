import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/content/content_bloc.dart';
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
          if (state.location == '/authentication' &&
              BlocProvider.of<ContentBloc>(context).state.validationState ==
                  ValidationState.invalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid API Key'),
              ),
            );
          }
          return null;
        });
  }
}
