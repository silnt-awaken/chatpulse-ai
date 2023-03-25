import 'dart:math';

class RandomConversations {
  static final List<String> _conversations = [
    'Hello',
    'How are you?',
    'I am fine',
    'What are you doing?',
    'I am coding',
    'What are you coding?',
    'I am coding a chat app',
    'What is the name of the app?',
    'It is called Chat App',
    'What is the name of the developer?',
  ];

  // create a function that gets a random conversation
  static String getRandomConversation() {
    final random = Random();
    final index = random.nextInt(_conversations.length);
    return _conversations[index];
  }
}
