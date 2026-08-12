import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/trace_db.dart';
import 'auth_rest_service.dart';

String API_KEY = "AIzaSyB9puHJBfrFuNNoFYBHXvUQFpO6kE7W4eQ";

class TraceRestService {
  final String collectionName = 'measurements_scope'; //'trace'; //'persons';
  final String baseUrl;
  final AuthRestService authService;
  String? _idToken;
  String? _refreshToken;

  TraceRestService({required this.baseUrl, required this.authService});

  void setTokens(String token, String refreshToken) {
    _idToken = token;
    _refreshToken = refreshToken;
  }

  // String replaceFirstCharWithRandom(String input) {
  //   if (input.isEmpty) return input;
  //
  //   final random = Random();
  //
  //   final randomChar = String.fromCharCode(random.nextInt(26) + 97); // 97 = 'a'
  //
  //    return randomChar + input.substring(1);
  // }

  // void damageToken() {
  //   _idToken = replaceFirstCharWithRandom(_idToken??'');
  // }

  Uri _buildUri(String path) {
    if (_idToken == null) {
      throw Exception('No ID Token');
    }
    return Uri.parse('$path?auth=$_idToken');
  }

  Future<String?> _getIdToken({bool forceRefresh = false}) async {
    if (forceRefresh && _refreshToken != null) {
      _idToken = await authService.refreshIdToken(_refreshToken!);
    }
    if (_idToken == null) throw Exception('No ID Token');
    return _idToken!;
  }

  Future<List<TraceDb>> getAllTraces() async {
    final uri = _buildUri('$baseUrl/$collectionName.json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data == null) return [];
      return data.entries.map((e) => TraceDb.fromJson(e.key, e.value)).toList();
    }
    else
    if (response.statusCode == 401) {
      print ("******* 401 *******");
      _idToken = await _getIdToken(forceRefresh: true);
      final uri_ = _buildUri('$baseUrl/$collectionName.json');
      final response_ = await http.get(uri_);
      if (response_.statusCode == 200) {
        final Map<String, dynamic>? data_ = jsonDecode(response_.body);
        if (data_ == null) return [];
        return data_.entries.map((e) => TraceDb.fromJson(e.key, e.value)).toList();
      }
      else {
        throw Exception('Load failed: ${response_.statusCode}');
      }
    }
    throw Exception('Load failed: ${response.statusCode}');
  }

  // Future<String> createTraceDb(TraceDb user) async {
  //   final uri = _buildUri('$baseUrl/$collectionName.json');
  //   final response = await http.post(
  //     uri,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(user.toJson()),
  //   );
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return jsonDecode(response.body)['name'];
  //   }
  //   throw Exception('Create failed: ${response.statusCode}');
  // }
}
