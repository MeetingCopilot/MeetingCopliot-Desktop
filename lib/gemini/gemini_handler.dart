import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiHandler {
  late final String _apiKey;

  late final String _modeName;

  late final GenerativeModel _model;

  late final ChatSession _chat;

  GeminiHandler(this._apiKey, this._modeName) {
    _model = GenerativeModel(model: _modeName, apiKey: _apiKey);
    _chat = _model.startChat(history: []);
  }

  Future<String?> sendMessage(String message) async {
    final content = [Content.text(message)];
    final response = await _model.generateContent(content);
    return response.text;
  }

  Stream<GenerateContentResponse> generateStream(String message) {
    final content = [Content.text(message)];
    final response = _model.generateContentStream(content);
    return response;
  }

  Future<GenerateContentResponse> chat(String message) {
    var content = Content.text(message);
    var response = _chat.sendMessage(content);
    return response;
  }

  Stream<GenerateContentResponse> chatStream(String message) {
    var content = Content.text(message);
    var response = _chat.sendMessageStream(content);
    return response;
  }
}
