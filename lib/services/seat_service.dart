import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/seat_availability.dart';


class SeatService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/seats/available';

  static Future<List<SeatAvailability>> getAvailableSeats({
    required DateTime date,
    required String startTime,
    required String endTime,
    int? buildingId,
    int? floorId,
    int? roomId,
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      if (buildingId != null) 'buildingId': buildingId.toString(),
      if (floorId != null) 'floorId': floorId.toString(),
      if (roomId != null) 'roomId': roomId.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SeatAvailability.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load seats');
    }
  }
}
