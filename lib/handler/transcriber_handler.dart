import 'dart:convert';
import 'dart:ffi';

import '../entity/transcriber_response.dart';

abstract class TranscriberHandler {
  /*
   * 识别准备完成，可以开始识别语音流
   */
  void onReady(TranscriberResponse response);

  /*
   * 检测到句子开始
   */
  void onSentenceBegin(TranscriberResponse response);

  /*
   * 句子结果变更
   */
  void onResultChanged(TranscriberResponse response);

  /*
   * 句子结束
   */
  void onSentenceEnd(TranscriberResponse response);

  /*
   * 识别完成，停止识别语音流
   */
  void onCompleted(TranscriberResponse response);

  void processMessage(String message) {
    TranscriberResponse response =
        TranscriberResponse.fromJson(jsonDecode(message));

    String? name = response.header.name;

    switch (name) {
      case 'TranscriptionStarted':
        // 开始识别
        onReady(response);
        break;
      case 'SentenceBegin':
        // 检测到句子开始
        onSentenceBegin(response);
        break;
      case 'TranscriptionResultChanged':
        // 句子结果变更
        onResultChanged(response);
        break;
      case 'SentenceEnd':
        // 句子结束
        onSentenceEnd(response);
        break;
      case 'TranscriptionCompleted':
        // 关闭识别（识别完成）
        onCompleted(response);
        break;
      default:
        // 未知，统一不处理
        print('Unknown event happened: $name');
        print('Message: $message');
        print('Response: ${json.encode(response)}');
        break;
    }
  }
}
