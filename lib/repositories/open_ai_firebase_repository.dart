import 'package:chatpulse_ai/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class OpenAIFirebaseRepository {
  final dio = Dio();
  String? apiKey;
  final url = 'https://api.openai.com/v1/chat/completions';

  final firestore = FirebaseFirestore.instance;
  final usersRef = FirebaseFirestore.instance.collection('users');
  late DocumentReference sessionRef;
  DocumentReference? userRef;
  String? currentChatSessionId;

  List<Message> history = [];
  String summary = '';

  assignUserRef(String userId) {
    userRef = usersRef.doc(userId);
    print('this is userRef: $userRef');
  }

  Future<bool> sendTextToOpenAI(String inputText, String userId) async {
    currentChatSessionId ??= userRef!.collection('chats').doc().id;
    sessionRef = userRef!.collection('chats').doc(currentChatSessionId);
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
    try {
      final response = await dio.post(
        url,
        data: {
          "model": "gpt-3.5-turbo-0301",
          "messages": messages,
        },
        options: Options(
          // Set the timeout in milliseconds, e.g., 5000 for 5 seconds
          receiveTimeout: const Duration(seconds: 5),
        ),
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
      return true;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectionTimeout ||
          e.type == DioErrorType.receiveTimeout) {
        // Remove the user message from the history

        // Handle the timeout error (e.g., show an error message to the user)
        print('Request timed out');
        return false;
      }

      history.removeLast();

      // Remove the user message from the Firestore
      await sessionRef.update({
        'messages': FieldValue.arrayRemove([userMessage.toJson()])
      });
      print(e.error);

      return false;
    }
  }

  Future<bool> validateApiKey(String? apiKey) async {
    late String fetchedApiKey;
    if (apiKey == null) {
      try {
        fetchedApiKey = await userRef!.get().then((value) => value['apiKey']);
      } catch (e) {
        return false;
      }
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers['authorization'] = 'Bearer ${apiKey ?? fetchedApiKey}';
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
        this.apiKey = apiKey ?? fetchedApiKey;
        print(userRef);
        await userRef!.set({'apiKey': apiKey}, SetOptions(merge: true));
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
    final chatSnapshots = userRef!.collection('chats').snapshots();

    return chatSnapshots.map((chatSnapshot) {
      return chatSnapshot.docs.map((chatDoc) {
        return chatDoc.data();
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getChatSessionsList() async {
    if (userRef == null) {
      await validateApiKey(null);
      if (userRef == null) {
        return [];
      } else {
        final chatSnapshots = await userRef!.collection('chats').get();
        return chatSnapshots.docs.map((chatDoc) {
          return chatDoc.data();
        }).toList();
      }
    } else {
      final chatSnapshots = await userRef!.collection('chats').get();
      return chatSnapshots.docs.map((chatDoc) {
        return chatDoc.data();
      }).toList();
    }
  }

  getMessagesFromChangedSession(String sessionId) async {
    currentChatSessionId = sessionId;
    final sessionSnapshot =
        await userRef!.collection('chats').doc(sessionId).get();
    final messages = sessionSnapshot.data()?['messages'] as List;
    history = messages.map((message) => Message.fromJson(message)).toList();
    summary = sessionSnapshot.data()?['summary'] as String;
  }
}
