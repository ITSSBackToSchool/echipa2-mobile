import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_session.dart';




class ApiService {
  // Android Emulator -> 10.0.2.2 | Web/desktop -> localhost
  static const String baseUrl = "http://10.0.2.2:8080/api/auth";
  static Future<Map<String, dynamic>?> getTrafficInfo(
      String origin, String destination) async {
    final url = Uri.parse("http://10.0.2.2:8080/api/traffic?origin=$origin&destination=$destination");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      print("Traffic API error: ${res.statusCode} -> ${res.body}");
      return null;
    }
  }

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
  static Future<List<Map<String, dynamic>>?> getUserReservations(int userId) async {
    final url = Uri.parse("http://10.0.2.2:8080/api/reservations/user/$userId");
    print(UserSession.token);
    final res = await http.get(url, headers: {
    "Content-Type": "application/json",
    if (UserSession.token != null)
    "Authorization": "Bearer ${UserSession.token}",
    });

    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      return body.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print("Reservation API error: ${res.statusCode} -> ${res.body}");
      return null;
    }
  }
}
