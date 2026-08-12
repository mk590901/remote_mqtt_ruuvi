import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trace_db.dart';

class TraceRestService {
  final String baseUrl;
  final String secret;

  final collectionName = 'measurements_scope'/*'trace'*/;
  
  TraceRestService({required this.baseUrl, required this.secret});

  Uri _buildUri(String path) => Uri.parse('$path?auth=$secret');

  Future<List<TraceDb>> getAllTraces() async {
    final uri = _buildUri('$baseUrl/$collectionName.json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data == null) return [];
      return data.entries.map((e) => TraceDb.fromJson(e.key, e.value)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<String> createTraceDb(TraceDb traceDb) async {
    final uri = _buildUri('$baseUrl/$collectionName.json');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(traceDb.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)['name'];
    }
    throw Exception('Create failed: ${response.statusCode}');
  }

  // Future<void> deleteUser(String id) async {
  //   final uri = _buildUri('$baseUrl/$collectionName/$id.json');
  //   await http.delete(uri);
  // }
}