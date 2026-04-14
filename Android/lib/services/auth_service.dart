import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.35.90.51:5005/api/auth';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        await _saveSession(decoded['token'], decoded['user']['id']);
        return decoded;
      } catch (e) {
        throw Exception('Server returned invalid data format.');
      }
    } else {
      try {
        final error = jsonDecode(response.body)['error'] ?? 'Login failed';
        throw Exception(error);
      } catch (e) {
        throw Exception('Server unreachable or returned an error.');
      }
    }
  }

  static Future<Map<String, dynamic>> register(String first, String last, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': first,
        'lastName': last,
        'email': email,
        'password': password
      }),
    );

    if (response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        await _saveSession(decoded['token'], decoded['user']['id']);
        return decoded;
      } catch (e) {
        throw Exception('Server returned invalid data format.');
      }
    } else {
      try {
        final error = jsonDecode(response.body)['error'] ?? 'Registration failed';
        throw Exception(error);
      } catch (e) {
        throw Exception('Server unreachable or returned an error.');
      }
    }
  }

  static Future<void> _saveSession(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
