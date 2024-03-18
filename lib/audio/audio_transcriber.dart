import 'dart:convert';
import 'dart:typed_data';
import 'package:meeting_copilot_desktop/handler/microphone_transcriber_handler.dart';
import 'package:meeting_copilot_desktop/handler/transcriber_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../nls/nls_access_token.dart';

class AudioTranscriber {
  final NlsAccessToken accessToken;

  final AudioRecorder _audioRecorder = AudioRecorder();

  late final InputDevice _inputDevice;

  late WebSocketChannel _transcriberChannel;

  late final TranscriberHandler _transcriberHandler;

  AudioTranscriber({
    required this.accessToken,
  });

  void startMicrophoneTranscriber(
      String deviceLabel, TranscriberHandler transcriberHandler) {
    _audioRecorder
        // 列出可用设备
        .listInputDevices()
        // 找到第一个匹配的设备（不存在就使用第一个）
        .then((devices) => devices.firstWhere(
            (device) => device.label == deviceLabel,
            orElse: () => devices.first))
        // 保存设备信息
        .then((device) => _inputDevice = device)
        .then(
          (value) => accessToken
              // 获取 token
              .getToken()
              // 创建 WSS 连接
              .then((token) => {_createTranscriberWss(token)})
              // 监听 WSS 连接
              .then((value) => _listeningTranscriber(transcriberHandler))
              // 发送识别起始指令
              .then((value) => _sendStartTranscription())
              // 开始录音，将录音数据发送到 WSS 连接
              .then((value) => _startTranscription()),
        );
  }

  void _createTranscriberWss(String token) {
    final wsUrl = Uri.parse(
        'wss://nls-gateway-cn-shanghai.aliyuncs.com/ws/v1?token=$token');
    _transcriberChannel = WebSocketChannel.connect(wsUrl);
  }

  void _listeningTranscriber(TranscriberHandler transcriberHandler) {
    _transcriberChannel.stream.listen(
      (message) {
        // print('Ws receive message: $message');
        transcriberHandler.processMessage(message);
      },
      onDone: () {
        print('Ws is done.');
        print('Close code: ${_transcriberChannel.closeReason}');
        if (_transcriberChannel.closeCode != status.goingAway) {
          print('Ws is closed.');
        }
      },
      onError: (error) {
        print('Ws occur error: $error');
      },
    );
  }

  void _sendStartTranscription() {
    Uuid uuid = const Uuid();
    String messageId = uuid.v4().replaceAll('-', '');
    String taskId = uuid.v4().replaceAll('-', '');

    Map<String, dynamic> headerMap = {
      'appkey': 'xbKnlAZFFi2UAmbr',
      'message_id': messageId,
      'task_id': taskId,
      'namespace': 'SpeechTranscriber',
      'name': 'StartTranscription',
    };

    Map<String, dynamic> payloadMap = {
      'format': 'pcm',
      'sample_rate': 16000,
      'enable_punctuation_prediction': true,
    };

    String payload = jsonEncode(
      {
        'header': headerMap,
        'payload': payloadMap,
      },
    );

    _transcriberChannel.sink.add(payload);
  }

  Future<void> _startTranscription() async {
    RecordConfig config = RecordConfig(
      device: _inputDevice,
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );

    Stream<Uint8List> recordStream = await _audioRecorder.startStream(config);

    recordStream.listen((data) {
      _transcriberChannel.sink.add(data);
    }, onDone: () {
      print('Stream closed');
    }, onError: (error) {
      print('Error: $error');
    });
  }

  void stopMicrophoneTranscriber() {
    _transcriberChannel.sink.close(status.goingAway);
    _audioRecorder.stop();
  }
}
