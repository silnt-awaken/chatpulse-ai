part of 'content_bloc.dart';

class ContentState extends Equatable {
  final ContentAuthStatus authStatus;
  final List<Message> history;
  final String summary;
  final String inputText;
  final ResponseStatus responseStatus;
  final String? userId;
  const ContentState({
    required this.authStatus,
    required this.history,
    required this.summary,
    required this.inputText,
    required this.responseStatus,
    this.userId,
  });

  @override
  List<Object> get props => [
        authStatus,
        history,
        summary,
        inputText,
        responseStatus,
        userId ?? false
      ];

  ContentState copyWith({
    ContentAuthStatus? authStatus,
    List<Message>? history,
    String? summary,
    String? inputText,
    ResponseStatus? responseStatus,
    String Function()? userId,
  }) {
    return ContentState(
      authStatus: authStatus ?? this.authStatus,
      history: history ?? this.history,
      summary: summary ?? this.summary,
      inputText: inputText ?? this.inputText,
      responseStatus: responseStatus ?? this.responseStatus,
      userId: userId != null ? userId() : this.userId,
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
