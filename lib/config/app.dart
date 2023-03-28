import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/content/content_bloc.dart';
import '../repositories/repositories.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository();
    final OpenAIFirebaseRepository openAIFirebaseRepository =
        OpenAIFirebaseRepository();
    final RouterRepository routerRepository = RouterRepository();
    final GoRouter router = routerRepository.router;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => openAIFirebaseRepository,
        ),
        RepositoryProvider(
          create: (context) => authRepository,
        ),
      ],
      child: BlocProvider(
        lazy: false,
        create: (context) =>
            ContentBloc(openAIFirebaseRepository, authRepository)
              ..add(ContentInitialEvent())
              ..add(ContentApiTrackerEvent()),
        child: BlocListener<ContentBloc, ContentState>(
          listener: (context, state) async {
            if (state.authStatus == ContentAuthStatus.authorized) {
              router.go('/');
            } else {
              router.go('/authentication');
            }

            if (state.validationState == ValidationState.invalid) {
              router.go('/authentication');
            }
          },
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
            routerDelegate: router.routerDelegate,
          ),
        ),
      ),
    );
  }
}
