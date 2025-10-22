import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator -> 10.0.2.2 | Web/desktop -> localhost
  static const String baseUrl = "http://10.0.2.2:8080/api/auth";

  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null; // 401 etc.
  }

  static Future<Map<String, dynamic>?> registerUser(
      String userName, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userName": userName, "email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }
}
