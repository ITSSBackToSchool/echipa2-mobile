import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_session.dart';

class BookSeatPage extends StatefulWidget {
  final int floorId;
  final DateTime selectedDate;
  final String entryTime;
  final String exitTime;

  const BookSeatPage({
    super.key,
    required this.floorId,
    required this.selectedDate,
    required this.entryTime,
    required this.exitTime,
  });

  @override
  State<BookSeatPage> createState() => _BookSeatPageState();
}

// Utility to convert 12h to 24h format
String convertTo24Hour(String time12h) {
  final regExp = RegExp(r'(\d+)(?::(\d+))?\s*([AP]M)', caseSensitive: false);
  final match = regExp.firstMatch(time12h);
  if (match == null) return "00:00:00"; // fallback

  int hour = int.parse(match.group(1)!);
  final minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
  final ampm = match.group(3)!.toUpperCase();

  if (ampm == "PM" && hour != 12) hour += 12;
  if (ampm == "AM" && hour == 12) hour = 0;

  return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00";
}

class _BookSeatPageState extends State<BookSeatPage> {
  List<RoomDTO> rooms = [];
  RoomDTO? selectedRoom;

  List<SeatAvailabilityDTO> seats = [];
  int? selectedSeatId;

  bool loadingRooms = false;
  bool loadingSeats = false;
  bool loadingBooking = false;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  // 🔹 Fetch rooms for the selected floor
  Future<void> fetchRooms() async {
    setState(() => loadingRooms = true);
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/rooms/floor/${widget.floorId}"),
        headers: {
          "Content-Type": "application/json",
          if (UserSession.token != null)
            "Authorization": "Bearer ${UserSession.token}",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          rooms = data.map((r) => RoomDTO.fromJson(r)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load rooms (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    } finally {
      setState(() => loadingRooms = false);
    }
  }

  // 🔹 Fetch available seats for selected room
  Future<void> fetchSeats(int roomId) async {
    setState(() => loadingSeats = true);
    try {
      final startTime = convertTo24Hour(widget.entryTime);
      final endTime = convertTo24Hour(widget.exitTime);
      final date = widget.selectedDate.toIso8601String().split('T').first;

      final response = await http.get(
        Uri.parse(
            "http://10.0.2.2:8080/api/seats/available?floorId=${widget.floorId}&roomId=$roomId&date=$date&startTime=${startTime}&endTime=${endTime}"),
        headers: {
          "Content-Type": "application/json",
          if (UserSession.token != null)
            "Authorization": "Bearer ${UserSession.token}",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          seats = data.map((s) => SeatAvailabilityDTO.fromJson(s)).toList();
          selectedSeatId = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load seats (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    } finally {
      setState(() => loadingSeats = false);
    }
  }

  Future<void> bookSeat() async {
    if (selectedSeatId == null) return;

    setState(() => loadingBooking = true);

    final body = {
      "userId": UserSession.userId ?? 1,
      "seatIds": selectedSeatId,
      "reservationDate": widget.selectedDate.toIso8601String().split('T').first,
      "startTime": widget.entryTime,
      "endTime": widget.exitTime,
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/reservations/seat"),
        headers: {
          "Content-Type": "application/json",
          if (UserSession.token != null)
            "Authorization": "Bearer ${UserSession.token}",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seat booked successfully ✅")),
        );
        Navigator.pushNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${response.statusCode}: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    } finally {
      setState(() => loadingBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Seat"),
        backgroundColor: const Color(0xFF004D4D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display selected date and times
            Text(
              "Date: ${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate.year}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Entry: ${widget.entryTime} | Exit: ${widget.exitTime}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Rooms dropdown
            loadingRooms
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<RoomDTO>(
              value: selectedRoom,
              decoration: const InputDecoration(
                labelText: "Select Room",
                border: OutlineInputBorder(),
              ),
              items: rooms
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r.name),
              ))
                  .toList(),
              onChanged: (r) {
                setState(() => selectedRoom = r);
                if (r != null) fetchSeats(r.id);
              },
            ),
            const SizedBox(height: 16),

            // Seats list
            Expanded(
              child: loadingSeats
                  ? const Center(child: CircularProgressIndicator())
                  : seats.isEmpty
                  ? const Center(child: Text("No seats available"))
                  : ListView.builder(
                itemCount: seats.length,
                itemBuilder: (context, index) {
                  final seat = seats[index];
                  final bool isSelected = seat.id == selectedSeatId;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF004D4D) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.event_seat, color: Color(0xFF004D4D)),
                      title: Text("Seat ${seat.seatNumber}"),
                      subtitle: !seat.isAvailable
                          ? Text(
                        "Reserved by ${seat.reservedBy}",
                        style: const TextStyle(color: Colors.red),
                      )
                          : null,
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF004D4D)) : null,
                      onTap: seat.isAvailable
                          ? () => setState(() => selectedSeatId = seat.id)
                          : null,
                    ),
                  );
                },
              ),
            ),

            // Book seat button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedSeatId != null && !loadingBooking ? bookSeat : null,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D4D)),
                child: loadingBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Book Seat", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Room model
class RoomDTO {
  final int id;
  final String name;

  RoomDTO({required this.id, required this.name});

  factory RoomDTO.fromJson(Map<String, dynamic> json) {
    return RoomDTO(id: json['id'], name: json['name']);
  }
}

// Seat model
class SeatAvailabilityDTO {
  final int id;
  final String seatNumber;
  final bool isAvailable;
  final String? reservedBy;

  SeatAvailabilityDTO({
    required this.id,
    required this.seatNumber,
    required this.isAvailable,
    this.reservedBy,
  });

  factory SeatAvailabilityDTO.fromJson(Map<String, dynamic> json) {
    return SeatAvailabilityDTO(
      id: json['id'],
      seatNumber: json['seatNumber'],
      isAvailable: json['isAvailable'],
      reservedBy: json['reservedBy'],
    );
  }
}
