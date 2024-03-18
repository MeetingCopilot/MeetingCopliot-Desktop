import 'dart:async';

import 'package:meeting_copilot_desktop/entity/transcriber_response.dart';
import 'package:meeting_copilot_desktop/handler/transcriber_handler.dart';

class MicrophoneTranscriberHandler extends TranscriberHandler {
  final StreamController<String> resultStream = StreamController<String>();

  @override
  void onReady(TranscriberResponse response) {
    print('onReady: $response');
  }

  @override
  void onSentenceBegin(TranscriberResponse response) {
    print('onSentenceBegin: $response');
  }

  @override
  void onResultChanged(TranscriberResponse response) {
    print('onResultChanged: $response');
  }

  @override
  void onSentenceEnd(TranscriberResponse response) {
    print('onSentenceEnd: $response');
    resultStream.sink.add(response.payload?['result']);
  }

  @override
  void onCompleted(TranscriberResponse response) {
    print('onCompleted: $response');
  }
}
