import 'dart:async';
import 'dart:convert';

import 'package:chatpulse_ai/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

  final StreamController<bool> apiKeyController = StreamController<bool>();
  Stream<bool> get apiKeyStream => apiKeyController.stream.asBroadcastStream();

  assignUserRef(String userId) {
    userRef = usersRef.doc(userId);
  }

  Future<List<Map<String, dynamic>>> prepareForStream(
      String inputText, String userId) async {
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

    return messages;
  }

  Future<Stream<List<Message>>> getOpenAIStreamResponse(
      List<Map<String, dynamic>> messages) async {
    history.add(Message(text: '', role: MessageRole.assistant.value));
    try {
      final response = await dio.post(
        url,
        data: {
          "model": "gpt-4-0314",
          "messages": messages,
          "stream": true,
          "temperature": 0.5,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 20),
          responseType: ResponseType.stream,
          persistentConnection: true,
        ),
      );

      final stream = response.data.stream;
      var buffer = <Message>[];
      var decoder = utf8.decoder;
      var transformer =
          StreamTransformer<Uint8List, List<Message>>.fromHandlers(
        handleData: (data, sink) {
          var lines = decoder.convert(data).split('\n');
          for (var line in lines) {
            if (line.startsWith('data: ')) {
              var payload = line.substring(6);
              if (payload == '[DONE]') {
                final wholeText = buffer.map((m) => m.text).join('');
                sessionRef.update({
                  'messages': FieldValue.arrayUnion([
                    Message(text: wholeText, role: MessageRole.assistant.value)
                        .toJson()
                  ]),
                });
                buffer = [];
                sink.add(buffer);
                sink.close();
              } else {
                var json = jsonDecode(payload);
                // make sure it doesn't contain "role", just want "content" from "delta"
                if (json.containsKey('choices') && !json.containsKey('role')) {
                  var choices = json['choices'] as List<dynamic>;
                  // cant contain "role" from json['choices'], only want "content" from "delta"
                  var content = choices
                      .map((c) => c.containsKey('delta') &&
                              c['delta'].containsKey('content')
                          ? c['delta']['content'] as String
                          : '')
                      .join('');
                  final message =
                      Message(text: content, role: MessageRole.assistant.value);

                  final tempHistory = List.of(history);
                  var lastMessageIndex = tempHistory.length - 1;
                  tempHistory[lastMessageIndex] = Message(
                      text: history[lastMessageIndex].text + message.text,
                      role: MessageRole.assistant.value);
                  history = tempHistory;

                  buffer.add(message);

                  sink.add(buffer);
                }
              }
            }
          }
        },
      );

      return stream.transform(transformer).asBroadcastStream();
    } catch (e) {
      if (history.last.role == MessageRole.assistant.value) {
        history.removeLast();
        history.removeLast();
      } else {
        history.removeLast();
      }
      return Stream.value([Message(text: '', role: MessageRole.none.value)])
          .asBroadcastStream();
    }
  }

  Future<bool> validateApiKey(String? apiKey) async {
    currentChatSessionId ??= userRef!.collection('chats').doc().id;
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
          "temperature": 2,
        },
      );

      if (response.statusCode == 200) {
        if (apiKey != null) {
          this.apiKey = apiKey;
        } else {
          this.apiKey = fetchedApiKey;
        }
        apiKeyController.add(true);
        await userRef!.set({'apiKey': this.apiKey}, SetOptions(merge: true));

        return true;
      } else {
        apiKeyController.add(false);
        return false;
      }
    } catch (e) {
      apiKeyController.add(false);
      return false;
    }
  }

  Future<String> getSummary() async {
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
        "temperature": 0.2,
      },
    );

    String responseText = response.data['choices'][0]['message']['content'];
    summary = responseText.trim();
    await sessionRef.update({'summary': summary});
    return summary;
  }

  newChatSession() {
    currentChatSessionId = userRef!.collection('chats').doc().id;
    history = [];
    summary = '';
  }

  Stream<List<Map<String, dynamic>>> getChatSessionsListFromStream() async* {
    yield* userRef!.collection('chats').snapshots().map((chatSnapshot) =>
        chatSnapshot.docs
            .map((chatDoc) => chatDoc.data())
            .where((element) =>
                element['messages'].length > 1 && element['summary'].isNotEmpty)
            .toList());
  }

  getMessagesFromChangedSession(String sessionId) async {
    currentChatSessionId = sessionId;
    final sessionSnapshot =
        await userRef!.collection('chats').doc(sessionId).get();
    final messages = sessionSnapshot.data()?['messages'] as List;
    history = messages.map((message) => Message.fromJson(message)).toList();
    summary = sessionSnapshot.data()?['summary'] as String;
  }

  Stream<List<Message>> getChatSessionMessagesStream() async* {
    yield* userRef!
        .collection('chats')
        .doc(currentChatSessionId)
        .snapshots()
        .map((chatSnapshot) {
      if (chatSnapshot.exists) {
        final messages = chatSnapshot.data()?['messages'] as List;
        return messages.map((message) => Message.fromJson(message)).toList();
      } else {
        return [];
      }
    });
  }

  deleteChatSession(String sessionId) async {
    await userRef!.collection('chats').doc(sessionId).delete();
    if (currentChatSessionId == sessionId) {
      newChatSession();
    }
  }
}

class ServerSentEventTransformer
    extends StreamTransformerBase<List<int>, String> {
  @override
  Stream<String> bind(Stream<List<int>> stream) {
    return stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => !line.startsWith(':') && line.isNotEmpty);
  }
}
