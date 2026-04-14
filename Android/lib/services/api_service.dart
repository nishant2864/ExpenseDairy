import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/finance_models.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS Simulator
  static const String baseUrl = 'http://10.35.90.51:5005/api';

  static Future<List<TransactionItem>> fetchTransactions(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/transactions/$userId'));
    
    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((v) => TransactionItem.fromJson(v)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  static Future<TransactionItem> addTransaction(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return TransactionItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add transaction');
    }
  }

  static Future<TransactionItem> smartLog(String userId, String input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/smart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'rawInput': input,
      }),
    );

    if (response.statusCode == 201) {
      return TransactionItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('AI Parsing failed');
    }
  }
}
