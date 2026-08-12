import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRestService {
  final String apiKey;

  AuthRestService({required this.apiKey});

  Future<Map<String, dynamic>> signInAnonymously() async {
    final response = await http.post(
      Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'returnSecureToken': true}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'idToken': data['idToken'],
        'refreshToken': data['refreshToken'],
      };
    }
    throw Exception('Anonymous signIn failed: ${response.body}');
  }

  Future<String> refreshIdToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('https://securetoken.googleapis.com/v1/token?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id_token'];
    }
    throw Exception('Token refresh failed: ${response.body}');
  }

}
