part of 'content_bloc.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object> get props => [];
}

class ContentInitialEvent extends ContentEvent {}

class ContentApiTrackerEvent extends ContentEvent {}

class ContentInputTextChangedEvent extends ContentEvent {
  final String text;
  const ContentInputTextChangedEvent({required this.text});
}

class ContentValidateAPIKeyEvent extends ContentEvent {
  final String apiKey;
  const ContentValidateAPIKeyEvent({required this.apiKey});
}

class ContentStartNewSessionEvent extends ContentEvent {}

class ContentChangeSessionsEvent extends ContentEvent {
  final String sessionId;
  const ContentChangeSessionsEvent({required this.sessionId});
}

class ContentChangeResponseStatusEvent extends ContentEvent {
  final ResponseStatus responseStatus;
  final bool hasDraggedWhileGenerating;
  const ContentChangeResponseStatusEvent(
      {required this.responseStatus, this.hasDraggedWhileGenerating = false});
}

class ContentResetEvent extends ContentEvent {}

class ContentCreateUserEvent extends ContentEvent {
  final String email;
  final String password;
  final String apiKey;
  const ContentCreateUserEvent(
      {required this.email, required this.password, required this.apiKey});
}

class ContentLogoutEvent extends ContentEvent {}

class ContentToggleDarkModeEvent extends ContentEvent {}

class ContentSendMessageForStreamEvent extends ContentEvent {
  final String text;
  const ContentSendMessageForStreamEvent({required this.text});
}

class ContentFetchSummaryEvent extends ContentEvent {}

class ContentDeleteChatSessionEvent extends ContentEvent {
  final String sessionId;
  const ContentDeleteChatSessionEvent({required this.sessionId});
}
