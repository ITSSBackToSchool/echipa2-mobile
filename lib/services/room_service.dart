import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room_model.dart';

class RoomService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/rooms';

  // Fetch all rooms (optional)
  static Future<List<Room>> getRooms() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  // ✅ Fetch available rooms by date
  static Future<List<Room>> getRoomsByDate({required DateTime date}) async {
    // Convert date to yyyy-MM-dd format
    final dateString = "${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";

    final url = Uri.parse('$baseUrl/available?date=$dateString');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load available rooms');
    }
  }
}
