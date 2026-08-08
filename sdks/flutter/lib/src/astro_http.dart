import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/models.dart';

class AstroHttpClient {
  final String baseUrl;
  final String? merchantKey;
  final String? bankKey;
  final String? adminKey;
  final Duration timeout;

  const AstroHttpClient({
    required this.baseUrl,
    this.merchantKey,
    this.bankKey,
    this.adminKey,
    this.timeout = const Duration(seconds: 30),
  });

  Map<String, String> get _defaultHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (merchantKey != null) headers['Authorization'] = 'Bearer $merchantKey';
    if (bankKey != null) headers['X-OpenWave-Bank-Key'] = bankKey!;
    if (adminKey != null) headers['X-OpenWave-Admin-Key'] = adminKey!;
    return headers;
  }

  Uri _uri(String path, [Map<String, String?>? params]) {
    var normalizedBaseUrl = baseUrl;
    while (normalizedBaseUrl.endsWith('/')) {
      normalizedBaseUrl = normalizedBaseUrl.substring(0, normalizedBaseUrl.length - 1);
    }
    final uri = Uri.parse('$normalizedBaseUrl$path');
    if (params == null) return uri;
    final clean = Map.fromEntries(
      params.entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)),
    );
    return clean.isEmpty ? uri : uri.replace(queryParameters: clean);
  }

  Future<dynamic> get(
    String path, {
    Map<String, String?>? params,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = {..._defaultHeaders, ...?extraHeaders};
    final response = await http.get(_uri(path, params), headers: headers).timeout(timeout);
    return _handle(response);
  }

  Future<dynamic> post(
    String path, [
    Object? body,
    Map<String, String>? extraHeaders,
  ]) async {
    final headers = {..._defaultHeaders, ...?extraHeaders};
    final response = await http
        .post(
          _uri(path),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
    return _handle(response);
  }

  Future<dynamic> patch(String path, [Object? body]) async {
    final response = await http
        .patch(
          _uri(path),
          headers: _defaultHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);
    return _handle(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: _defaultHeaders).timeout(timeout);
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    final body = decoded is Map<String, dynamic> ? decoded : null;
    final nested = body?['error'];
    final err = nested is Map<String, dynamic> ? nested : body;
    throw AstroError(
      code: err?['code'] as String? ?? 'UNKNOWN_ERROR',
      message: nested is String
          ? nested
          : err?['message'] as String? ?? 'HTTP ${response.statusCode}',
      statusCode: response.statusCode,
      detail: err?['detail'] as String?,
    );
  }
}
