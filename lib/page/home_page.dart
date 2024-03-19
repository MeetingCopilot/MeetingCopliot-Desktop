import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meeting_copilot_desktop/audio/audio_transcriber.dart';
import 'package:meeting_copilot_desktop/audio/recorder.dart';
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

  final List<String> _transcriptions = [];

  @override
  void initState() {
    super.initState();
    _recorder = Recorder();
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
      setState(() {
        _transcriptions.add(data);
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _resultStream.close();
    _scrollController.dispose();
    print('disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 30,
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
            flex: 70,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _transcriptions.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Center(
                    child: Text(_transcriptions[index]),
                  ),
                );
              },
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
    );
  }
}
