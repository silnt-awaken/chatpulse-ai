part of 'content_bloc.dart';

class ContentState extends Equatable {
  final ContentAuthStatus authStatus;
  final List<Message> history;
  final String summary;
  final String inputText;
  final ResponseStatus responseStatus;
  final String? userId;
  final bool isDarkMode;
  final ValidationState validationState;
  const ContentState({
    required this.authStatus,
    required this.history,
    required this.summary,
    required this.inputText,
    required this.responseStatus,
    this.userId,
    required this.isDarkMode,
    required this.validationState,
  });

  @override
  List<Object> get props => [
        authStatus,
        history,
        summary,
        inputText,
        responseStatus,
        userId ?? false,
        isDarkMode,
        validationState,
      ];

  ContentState copyWith({
    ContentAuthStatus? authStatus,
    List<Message>? history,
    String? summary,
    String? inputText,
    ResponseStatus? responseStatus,
    String Function()? userId,
    bool? isDarkMode,
    ValidationState? validationState,
  }) {
    return ContentState(
      authStatus: authStatus ?? this.authStatus,
      history: history ?? this.history,
      summary: summary ?? this.summary,
      inputText: inputText ?? this.inputText,
      responseStatus: responseStatus ?? this.responseStatus,
      userId: userId != null ? userId() : this.userId,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      validationState: validationState ?? this.validationState,
    );
  }
}

enum ContentAuthStatus {
  unauthorized,
  authorized,
}

enum ResponseStatus {
  idle,
  waiting,
  success,
  failed,
}

enum ValidationState {
  none,
  validating,
  validated,
  invalid,
}
