import 'dart:convert';

import 'package:http/http.dart' as http;

/// Klien HTTP tipis untuk backend FastAPI SMK Negeri 1 Pati.
///
/// Menyimpan base URL dan token bearer yang dibagi antara [ApiAuthService]
/// dan [ApiDataService].
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  /// Mis. `http://localhost:8000`. Tanpa garis miring di akhir.
  final String baseUrl;
  final http.Client _client;

  /// Token bearer aktif; di-set oleh [ApiAuthService] setelah login.
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Never _throw(http.Response res) {
    String message = 'Terjadi kesalahan (${res.statusCode})';
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {/* biarkan pesan default */}
    throw ApiException(message, res.statusCode);
  }

  Future<dynamic> get(String path) async {
    final res = await _client.get(_uri(path), headers: _headers);
    if (res.statusCode >= 400) _throw(res);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Object? body) async {
    final res = await _client.post(_uri(path),
        headers: _headers, body: jsonEncode(body));
    if (res.statusCode >= 400) _throw(res);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> put(String path, Object? body) async {
    final res = await _client.put(_uri(path),
        headers: _headers, body: jsonEncode(body));
    if (res.statusCode >= 400) _throw(res);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<void> delete(String path) async {
    final res = await _client.delete(_uri(path), headers: _headers);
    if (res.statusCode >= 400) _throw(res);
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
  @override
  String toString() => message;
}
