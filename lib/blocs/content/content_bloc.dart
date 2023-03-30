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
          validationState: ValidationState.none,
          hasDraggedWhileGenerating: false,
          generationFinished: true,
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
              authStatus: ContentAuthStatus.authorized,
              userId: () => user.uid,
              validationState: ValidationState.validating);
        } else {
          return state.copyWith(authStatus: ContentAuthStatus.unauthorized);
        }
      });
    });

    on<ContentApiTrackerEvent>((event, emit) async {
      await emit.forEach<bool>(openAIFirebaseRepository.apiKeyStream,
          onData: (isValidated) {
        if (isValidated) {
          return state.copyWith(validationState: ValidationState.validated);
        } else {
          return state.copyWith(validationState: ValidationState.invalid);
        }
      });
    });

    on<ContentInputTextChangedEvent>((event, emit) {
      emit(state.copyWith(inputText: event.text));
    });

    on<ContentStartNewSessionEvent>((event, emit) {
      openAIFirebaseRepository.newChatSession();
      emit(state.copyWith(
          history: openAIFirebaseRepository.history,
          summary: openAIFirebaseRepository.summary,
          responseStatus: ResponseStatus.idle,
          inputText: ''));
    });

    on<ContentChangeSessionsEvent>((event, emit) async {
      await openAIFirebaseRepository
          .getMessagesFromChangedSession(event.sessionId);
      emit(state.copyWith(
        history: openAIFirebaseRepository.history,
        summary: openAIFirebaseRepository.summary,
        responseStatus: ResponseStatus.idle,
      ));
    });

    on<ContentChangeResponseStatusEvent>((event, emit) async {
      emit(state.copyWith(
          responseStatus: event.responseStatus,
          hasDraggedWhileGenerating: event.hasDraggedWhileGenerating));
      if (event.hasDraggedWhileGenerating &&
          event.responseStatus == ResponseStatus.idle) {
        await Future.delayed(const Duration(seconds: 5));
        emit(state.copyWith(
            responseStatus: ResponseStatus.generating,
            hasDraggedWhileGenerating: false));
      }
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
    });

    on<ContentCreateUserEvent>((event, emit) async {
      await authRepository.createUserWithEmailAndPassword(
          event.email, event.password);
      final isValid =
          await openAIFirebaseRepository.validateApiKey(event.apiKey);
      emit(state.copyWith(
          authStatus: isValid
              ? ContentAuthStatus.authorized
              : ContentAuthStatus.unauthorized,
          validationState: ValidationState.validated));
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

    on<ContentToggleDarkModeEvent>((event, emit) {
      emit(state.copyWith(isDarkMode: !state.isDarkMode));
    });

    on<ContentSendMessageForStreamEvent>((event, emit) async {
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
        generationFinished: false,
      ));
      final messages = await openAIFirebaseRepository.prepareForStream(
          event.text, state.userId!);
      await emit.forEach<List<Message>>(
          await openAIFirebaseRepository.getOpenAIStreamResponse(messages),
          onData: (List<Message> data) {
        if (data.isEmpty) {
          return state.copyWith(
              responseStatus: ResponseStatus.success, generationFinished: true);
        } else {
          if (data.length == 1) {
            if (data[0].role == 'none') {
              return state.copyWith(
                  responseStatus: ResponseStatus.failed,
                  history: openAIFirebaseRepository.history);
            } else {
              return state.copyWith(
                history: openAIFirebaseRepository.history,
                responseStatus: ResponseStatus.generating,
              );
            }
          } else {
            return state.copyWith(
              history: openAIFirebaseRepository.history,
              responseStatus: ResponseStatus.generating,
            );
          }
        }
      });
    });

    on<ContentFetchSummaryEvent>((event, emit) async {
      await openAIFirebaseRepository.getSummary();
      emit(state.copyWith(
          summary: openAIFirebaseRepository.summary,
          hasDraggedWhileGenerating: false));
    });

    on<ContentDeleteChatSessionEvent>((event, emit) async {
      await openAIFirebaseRepository.deleteChatSession(event.sessionId);
      emit(state.copyWith(
        history: openAIFirebaseRepository.history,
        summary: openAIFirebaseRepository.summary,
        responseStatus: ResponseStatus.idle,
        inputText: '',
      ));
    });
  }
}
