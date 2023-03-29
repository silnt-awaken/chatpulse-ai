import 'package:chatpulse_ai/blocs/content/content_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MicButton extends StatefulWidget {
  const MicButton(
      {super.key,
      required this.isDarkMode,
      required this.textEditingController});
  final bool isDarkMode;
  final TextEditingController textEditingController;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  bool isPressed = false;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      widget.textEditingController.text = _lastWords;
      context
          .read<ContentBloc>()
          .add(ContentInputTextChangedEvent(text: _lastWords));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        setState(() {
          isPressed = true;
        });
        _startListening();
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          isPressed = false;
        });
        _stopListening();
      },
      child: AnimatedContainer(
        height: 40,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE0E5EC),
          boxShadow: widget.isDarkMode
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                  ),
                ]
              : isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(-3, -3),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(3, 3),
                        blurRadius: 8,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(-6, -6),
                        blurRadius: 16,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(6, 6),
                        blurRadius: 16,
                      ),
                    ],
        ),
        child: Center(
            child: AnimatedOpacity(
          opacity: isPressed ? 1 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.mic,
              color: Colors.red,
            ),
          ),
        )),
      ),
    );
  }
}
