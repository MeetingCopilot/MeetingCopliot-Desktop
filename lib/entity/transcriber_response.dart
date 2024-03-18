import 'dart:collection';
import 'dart:convert';

class TranscriberResponse {
  Header header;

  Map<String, dynamic>? payload;

  TranscriberResponse.fromJson(Map<String, dynamic> json)
      : header = Header.fromJson(json['header']),
        payload = json['payload'];

  Map<String, dynamic> toJson() => {
        'header': header.toJson(),
        'payload': payload,
      };

  @override
  String toString() {
    return 'TranscriberResponse{header: $header, payload: $payload}';
  }
}

class Header {
  String? namespace;
  String? name;
  int? status;
  String? messageId;
  String? taskId;
  String? statusText;

  Header.fromJson(Map<String, dynamic> json)
      : namespace = json['namespace'],
        name = json['name'],
        status = json['status'],
        messageId = json['message_id'],
        taskId = json['task_id'],
        statusText = json['status_text'];

  Map<String, dynamic> toJson() => {
        'namespace': namespace,
        'name': name,
        'status': status,
        'message_id': messageId,
        'task_id': taskId,
        'status_text': statusText,
      };
}
