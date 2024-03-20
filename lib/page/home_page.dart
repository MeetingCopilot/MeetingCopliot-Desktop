import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meeting_copilot_desktop/audio/audio_transcriber.dart';
import 'package:meeting_copilot_desktop/audio/recorder.dart';
import 'package:meeting_copilot_desktop/component/conversation_block.dart';
import 'package:meeting_copilot_desktop/entity/conversation.dart';
import 'package:meeting_copilot_desktop/gemini/gemini_handler.dart';
import 'package:meeting_copilot_desktop/handler/microphone_transcriber_handler.dart';
import 'package:meeting_copilot_desktop/nls/nls_access_token.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Recorder _recorder;

  List<String> _deviceLabels = [];

  String _selectedDevice = '';

  final _audioTranscriber = AudioTranscriber(
      accessToken: NlsAccessToken(
    accessKeyId: 'LTAI5tMkp2heQUT5dGuwnH5x',
    accessSecret: 'Z9Ae3522vYiQH3yQz2e3wAhQi1Ob7N',
  ));

  final MicrophoneTranscriberHandler _transcriberHandler =
      MicrophoneTranscriberHandler();

  late final StreamController<String> _resultStream;

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _textEditingController = TextEditingController();

  final List<Conversation> _conversations = [];

  late final GeminiHandler _geminiHandler;

  @override
  void initState() {
    super.initState();
    _recorder = Recorder();
    _geminiHandler =
        GeminiHandler('AIzaSyDw5jXunz0bX3q5gu8TaSkRgIk88G1T940', 'gemini-pro');
    _recorder.listDevices().then(
          (devices) => setState(
            () {
              _deviceLabels = devices;
              _selectedDevice = _deviceLabels.first;
            },
          ),
        );
    _resultStream = _transcriberHandler.resultStream;

    _transcriberHandler.resultStream.stream.listen((data) {
      Conversation conversation = Conversation(
        question: data,
        answer: '正在处理...',
      );

      _conversations.add(conversation);
      Future.value(data).then(
          (value) => {
                _geminiHandler.chat(value).then(
                    (response) => setState(() {
                          conversation.answer = response;
                        }),
                    onError: (e) => {
                          setState(() {
                            conversation.answer = '处理失败';
                          })
                        })
              },
          onError: (e) => {
                setState(() {
                  conversation.answer = '处理失败';
                })
              });
    });
  }

  @override
  void dispose() {
    _resultStream.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 25,
            child: Container(
              color: Colors.grey[100],
              child: DropdownButton<String>(
                value: _selectedDevice,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDevice = newValue!;
                  });
                },
                items:
                    _deviceLabels.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value, // Ensure each value is unique
                    child: Text(value),
                  );
                }).toList(), // Convert to set to remove duplicates
              ),
            ),
          ),
          Expanded(
            flex: 75,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _conversations.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ConversationBlock(
                        conversation: _conversations[index],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: '请输入消息...',
                      border: const OutlineInputBorder(),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.transparent,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_upward_outlined,
                              size: 36,
                            ),
                            onPressed: () async {
                              processInput(_textEditingController.text);
                            },
                          ),
                        ),
                      ),
                    ),
                    onSubmitted: (String value) {
                      processInput(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _audioTranscriber.startMicrophoneTranscriber(
            _selectedDevice,
            _transcriberHandler,
          );
        },
        tooltip: 'Start record',
        child: const Icon(Icons.keyboard_voice_sharp),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void processInput(String text) {
    if (text.isEmpty) {
      return;
    }

    Conversation conversation = Conversation(
      question: text,
      answer: '正在处理...',
    );
    setState(() {
      _conversations.add(conversation);
    });
    _geminiHandler.chat(text).then(
        (response) => setState(() {
              conversation.answer = response;
            }),
        onError: (e) => {
              setState(() {
                conversation.answer = '处理失败';
              })
            });
    _textEditingController.text = '';
  }
}
