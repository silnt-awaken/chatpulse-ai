import 'package:chatpulse_ai/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class OpenAIFirebaseRepository {
  final dio = Dio();
  late String apiKey;
  final url = 'https://api.openai.com/v1/chat/completions';

  final firestore = FirebaseFirestore.instance;
  final usersRef = FirebaseFirestore.instance.collection('users');
  late DocumentReference sessionRef;
  late DocumentReference userRef;
  String? currentChatSessionId;

  List<Message> history = [];
  String summary = '';

  sendTextToOpenAI(String inputText, String userId) async {
    userRef = usersRef.doc(userId);
    currentChatSessionId ??= userRef.collection('chats').doc().id;
    sessionRef = userRef.collection('chats').doc(currentChatSessionId);
    DocumentSnapshot sessionSnapshot = await sessionRef.get();

    final userMessage = Message(text: inputText, role: MessageRole.user.value);
    history.add(userMessage);

    if (sessionSnapshot.exists) {
      await sessionRef.update({
        'messages': FieldValue.arrayUnion([userMessage.toJson()])
      });
    } else {
      await sessionRef.set({
        'messages': [userMessage.toJson()],
        'summary': '',
        'sessionId': currentChatSessionId,
      });
    }

    final messages = [
      ...history.map((message) => message.toJson()),
    ];

    final response = await dio.post(
      url,
      data: {
        "model": "gpt-3.5-turbo-0301",
        "messages": messages,
      },
    );

    String responseText = response.data['choices'][0]['message']['content'];
    final assistantMessage =
        Message(text: responseText, role: MessageRole.assistant.value);
    history.add(assistantMessage);

    summary = await getSummary(history);
    sessionRef.update({
      'messages': FieldValue.arrayUnion([assistantMessage.toJson()]),
      'summary': summary
    });
  }

  Future<bool> validateApiKey(String apiKey) async {
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers['authorization'] = 'Bearer $apiKey';
    try {
      final response = await dio.post(
        url,
        data: {
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": "a"}
          ],
          "max_tokens": 1,
          "temperature": 1.1
        },
      );

      if (response.statusCode == 200) {
        this.apiKey = apiKey;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> getSummary(List<Message> history) async {
    String readableHistory = '';
    for (Message message in history) {
      String role =
          message.role == MessageRole.user.value ? 'User' : 'Assistant';
      readableHistory += '$role: ${message.text}\n';
    }

    readableHistory = readableHistory.trim();

    String prompt =
        'Please create a short, 1 sentence summary (3-5 words max) of the following conversation:\n\n$readableHistory\n';

    final response = await dio.post(
      url,
      data: {
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 1.1
      },
    );

    String responseText = response.data['choices'][0]['message']['content'];
    final summary = responseText.trim();
    return summary;
  }

  newChatSession() {
    currentChatSessionId = null;
    history = [];
    summary = '';
  }

  Stream<List<Map<String, dynamic>>> getChatSessions() {
    final chatSnapshots = userRef.collection('chats').snapshots();

    return chatSnapshots.map((chatSnapshot) {
      return chatSnapshot.docs.map((chatDoc) {
        return chatDoc.data();
      }).toList();
    });
  }

  getMessagesFromChangedSession(String sessionId) async {
    currentChatSessionId = sessionId;
    final sessionSnapshot =
        await userRef.collection('chats').doc(sessionId).get();
    final messages = sessionSnapshot.data()?['messages'] as List;
    history = messages.map((message) => Message.fromJson(message)).toList();
    summary = sessionSnapshot.data()?['summary'] as String;
  }
}
