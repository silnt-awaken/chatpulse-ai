import 'package:bloc/bloc.dart';
import 'package:chatpulse_ai/models/message.dart';
import 'package:chatpulse_ai/repositories/auth_repository.dart';
import 'package:chatpulse_ai/repositories/open_ai_firebase_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final OpenAIFirebaseRepository openAIFirebaseRepository;
  final AuthRepository authRepository;
  ContentBloc(this.openAIFirebaseRepository, this.authRepository)
      : super(const ContentState(
          authStatus: ContentAuthStatus.authorized, //temporary
          history: [],
          summary: '',
          inputText: '',
          responseStatus: ResponseStatus.idle,
          isDarkMode: false,
        )) {
    on<ContentInitialEvent>((event, emit) async {
      await emit.forEach<User?>(authRepository.authStateChanges,
          onData: (user) {
        if (user != null) {
          openAIFirebaseRepository.assignUserRef(user.uid);
          if (openAIFirebaseRepository.apiKey == null) {
            openAIFirebaseRepository.validateApiKey(null);
          }

          return state.copyWith(
              authStatus: ContentAuthStatus.authorized, userId: () => user.uid);
        } else {
          return state.copyWith(authStatus: ContentAuthStatus.unauthorized);
        }
      });
    });

    on<ContentApiTrackerEvent>((event, emit) async {
      await emit.forEach<String>(openAIFirebaseRepository.apiKeyStream,
          onData: (apiKey) {
        return state.copyWith(apiKey: () => apiKey);
      });
    });

    on<ContentInputTextChangedEvent>((event, emit) {
      emit(state.copyWith(inputText: event.text));
    });

    on<ContentSendTextEvent>((event, emit) async {
      if (state.userId == null) return;
      emit(state.copyWith(
        history: [
          ...state.history,
          Message(
            text: event.text,
            role: 'user',
          )
        ],
        responseStatus: ResponseStatus.waiting,
      ));
      final hasSuccessfullySent = await openAIFirebaseRepository
          .sendTextToOpenAI(event.text, state.userId!);
      emit(state.copyWith(
        history: openAIFirebaseRepository.history,
        summary: openAIFirebaseRepository.summary,
        responseStatus: hasSuccessfullySent
            ? ResponseStatus.success
            : ResponseStatus.failed,
      ));

      openAIFirebaseRepository.historyStreamController
          .add(openAIFirebaseRepository.history);
    });

    on<ContentStartNewSessionEvent>((event, emit) {
      openAIFirebaseRepository.newChatSession();
      emit(state.copyWith(
          history: openAIFirebaseRepository.history,
          summary: openAIFirebaseRepository.summary,
          responseStatus: ResponseStatus.idle,
          inputText: ''));

      openAIFirebaseRepository.historyStreamController
          .add(openAIFirebaseRepository.history);
    });

    on<ContentChangeSessionsEvent>((event, emit) async {
      await openAIFirebaseRepository
          .getMessagesFromChangedSession(event.sessionId);
      emit(state.copyWith(
        history: openAIFirebaseRepository.history,
        summary: openAIFirebaseRepository.summary,
        responseStatus: ResponseStatus.idle,
      ));

      openAIFirebaseRepository.historyStreamController
          .add(openAIFirebaseRepository.history);
    });

    on<ContentChangeResponseStatusEvent>((event, emit) {
      emit(state.copyWith(responseStatus: event.responseStatus));
    });

    on<ContentResetEvent>((event, emit) async {
      await openAIFirebaseRepository.newChatSession();
      emit(state.copyWith(
        authStatus: ContentAuthStatus.unauthorized,
        history: openAIFirebaseRepository.history,
        summary: openAIFirebaseRepository.summary,
        inputText: '',
        responseStatus: ResponseStatus.idle,
      ));

      openAIFirebaseRepository.historyStreamController
          .add(openAIFirebaseRepository.history);
    });

    on<ContentCreateUserEvent>((event, emit) async {
      await authRepository.createUserWithEmailAndPassword(
          event.email, event.password);
      final isValid =
          await openAIFirebaseRepository.validateApiKey(event.apiKey);
      emit(state.copyWith(
          authStatus: isValid
              ? ContentAuthStatus.authorized
              : ContentAuthStatus.unauthorized));
    });

    on<ContentLogoutEvent>((event, emit) async {
      await openAIFirebaseRepository.newChatSession();
      await authRepository.signOut();
      emit(state.copyWith(
          history: openAIFirebaseRepository.history,
          summary: openAIFirebaseRepository.summary,
          inputText: '',
          responseStatus: ResponseStatus.idle));

      openAIFirebaseRepository.historyStreamController
          .add(openAIFirebaseRepository.history);
    });

    on<ContentToggleDarkModeEvent>((event, emit) {
      emit(state.copyWith(isDarkMode: !state.isDarkMode));
    });
  }
}
