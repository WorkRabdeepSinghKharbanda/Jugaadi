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

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final res = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    return _decode(res);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  /// The backend's `{"error": "..."}` message, or the raw body if it isn't that shape.
  String get message {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is String) return decoded['error'] as String;
    } catch (_) {
      // not JSON — fall through to the raw body
    }
    return body;
  }

  /// The backend's `{"code": "..."}` field (e.g. 'plan_limit'), or null if absent/not JSON.
  String? get code {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['code'] is String) return decoded['code'] as String;
    } catch (_) {
      // not JSON
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $body';
}

/// User-facing message for an error caught from an API call — never the raw exception
/// toString() (e.g. `ApiException(500): {"error": "..."}`), which leaks backend internals.
String apiErrorMessage(Object error) => error is ApiException ? error.message : 'Something went wrong';
