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
        )) {
    on<ContentInitialEvent>((event, emit) async {
      await emit.forEach<User?>(authRepository.authStateChanges,
          onData: (user) {
        if (user != null) {
          openAIFirebaseRepository.assignUserRef(user.uid);
          return state.copyWith(
              authStatus: ContentAuthStatus.authorized, userId: () => user.uid);
        } else {
          return state.copyWith(authStatus: ContentAuthStatus.unauthorized);
        }
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
      await openAIFirebaseRepository.sendTextToOpenAI(
          event.text, state.userId!);
      emit(state.copyWith(
        history: openAIFirebaseRepository.history,
        summary: openAIFirebaseRepository.summary,
        responseStatus: ResponseStatus.success,
      ));
    });

    on<ContentStartNewSessionEvent>((event, emit) {
      openAIFirebaseRepository.newChatSession();
      emit(state.copyWith(
          history: openAIFirebaseRepository.history,
          summary: openAIFirebaseRepository.summary));
    });

    on<ContentChangeSessionsEvent>((event, emit) async {
      await openAIFirebaseRepository
          .getMessagesFromChangedSession(event.sessionId);
      emit(state.copyWith(
          history: openAIFirebaseRepository.history,
          summary: openAIFirebaseRepository.summary));
    });

    on<ContentChangeResponseStatusEvent>((event, emit) {
      emit(state.copyWith(responseStatus: event.responseStatus));
    });

    on<ContentResetEvent>((event, emit) async {
      await openAIFirebaseRepository.newChatSession();
      emit(ContentState(
        authStatus: ContentAuthStatus.unauthorized,
        history: openAIFirebaseRepository.history,
        summary: openAIFirebaseRepository.summary,
        inputText: '',
        responseStatus: ResponseStatus.idle,
      ));
    });

    on<ContentCreateUserEvent>((event, emit) async {
      final isApiKeyValid =
          await openAIFirebaseRepository.validateApiKey(event.apiKey);
      if (isApiKeyValid) {
        await authRepository.createUserWithEmailAndPassword(
            event.email, event.password);
      } else {
        return;
      }
    });

    on<ContentLogoutEvent>((event, emit) async {
      await openAIFirebaseRepository.newChatSession();
      await authRepository.signOut();
      emit(state.copyWith(
          history: openAIFirebaseRepository.history,
          summary: openAIFirebaseRepository.summary,
          inputText: '',
          responseStatus: ResponseStatus.idle));
    });
  }
}
