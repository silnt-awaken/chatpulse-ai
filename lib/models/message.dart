class Message {
  final String text;
  final String role;

  Message({
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
}

enum MessageRole {
  user("user"),
  assistant("assistant");

  final String value;
  const MessageRole(this.value);
}
