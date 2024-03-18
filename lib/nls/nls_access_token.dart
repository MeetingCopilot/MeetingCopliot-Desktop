import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class NlsAccessToken {
  final String _accessKeyId;

  final String _accessSecret;

  NlsAccessToken({required String accessKeyId, required String accessSecret})
      : _accessKeyId = accessKeyId,
        _accessSecret = accessSecret;

  Future<String> getToken() async {
    DateTime dateTime = DateTime.now().toUtc();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    String formattedDateTime = dateFormat.format(dateTime);

    Map<String, String> queryParamsMap = {
      'AccessKeyId': _accessKeyId,
      'Action': 'CreateToken',
      'Version': '2019-02-28',
      'RegionId': 'cn-shanghai',
      'Timestamp': formattedDateTime,
      'Format': 'JSON',
      'SignatureMethod': 'HMAC-SHA1',
      'SignatureVersion': '1.0',
      'SignatureNonce': const Uuid().v4(),
    };

    List<String> keys = queryParamsMap.keys.toList();
    keys.sort();

    StringBuffer queryString = StringBuffer();
    for (var key in keys) {
      queryString.write('&');
      queryString.write(key);
      queryString.write('=');
      queryString.write(Uri.encodeComponent(queryParamsMap[key]!));
    }

    String queryParam = queryString.toString().substring(1);

    String signString = Uri.encodeComponent(queryParam)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');

    final hMacSha1 = Hmac.sha1();
    final sha1 = await hMacSha1.calculateMac(
      utf8.encode('GET&%2F&$signString'),
      secretKey: SecretKey(utf8.encode('$_accessSecret&')),
    );

    String signature = base64Encode(sha1.bytes);

    queryParamsMap['Signature'] = signature;

    HttpClient httpClient = HttpClient();
    Uri uri = Uri(
      scheme: 'http',
      host: 'nls-meta.cn-shanghai.aliyuncs.com',
      queryParameters: queryParamsMap,
    );

    HttpClientRequest request = await httpClient.getUrl(uri);
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();

    Map<String, dynamic> resultMap = json.decode(responseBody);
    String token = resultMap['Token']['Id'];

    return token;
  }
}
