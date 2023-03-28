import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String text;
  final String role;

  const Message({
    required this.text,
    required this.role,
  });

  Message copyWith({
    String? text,
    String? role,
  }) {
    return Message(
      text: text ?? this.text,
      role: role ?? this.role,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      text: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': text,
    };
  }

  @override
  List<Object> get props => [text, role];

  @override
  String toString() => 'Message { text: $text, role: $role }';
}

enum MessageRole {
  user("user"),
  assistant("assistant");

  final String value;
  const MessageRole(this.value);
}
