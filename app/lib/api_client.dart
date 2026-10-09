import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Talks to the Jugaadi backend (Render) — never calls Supabase tables directly.
class ApiClient {
  ApiClient(this.baseUrl);

  final String baseUrl;

  Future<Map<String, String>> _headers() async {
    final session = Supabase.instance.client.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  Future<dynamic> _decode(http.Response res) {
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, res.body);
    }
    return Future.value(res.body.isEmpty ? null : jsonDecode(res.body));
  }

  Future<dynamic> get(String path, [Map<String, dynamic>? query]) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
    final res = await http.get(uri, headers: await _headers());
    return _decode(res);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'ApiException($statusCode): $body';
}
