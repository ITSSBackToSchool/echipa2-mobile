import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';
import '../models/user_session.dart';
class ReservationApi {
  static const baseUrl = "http://localhost:8080/api/reservations";

  static Future<List<Reservation>> getUserReservations(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reservations');
    }
  }

  static Future<void> createSeatReservation(
      int userId, List<int> seatIds, String date, String startTime, String endTime) async {
    final body = json.encode({
      "userId": userId,
      "seatId": seatIds,
      "reservationDate": date,
      "startTime": startTime,
      "endTime": endTime,
    });

    final response = await http.post(Uri.parse('$baseUrl/seat'),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to create seat reservation');
    }
  }

  static Future<void> createRoomReservation(
      int userId, int roomId, String date, String startTime, String endTime) async {
    final body = json.encode({
      "userId": userId,
      "roomIds": roomId,
      "reservationDate": date,
      "startTime": startTime,
      "endTime": endTime,
    });

    final response = await http.post(Uri.parse('$baseUrl/room'),
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to create room reservation');
    }
  }

  static Future<void> cancelReservation(int reservationId) async {
    final url = Uri.parse("http://10.0.2.2:8080/api/reservations/$reservationId");
    final res = await http.delete(url, headers: {
      "Content-Type": "application/json",
      if (UserSession.token != null) "Authorization": "Bearer ${UserSession.token}"
    });
    if (res.statusCode != 204) {
      throw Exception("Failed to cancel reservation");
    }
  }

}
