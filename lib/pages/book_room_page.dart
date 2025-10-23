import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_session.dart';

class BookRoomPage extends StatefulWidget {
  const BookRoomPage({super.key});

  @override
  State<BookRoomPage> createState() => _BookRoomPageState();
}

class _BookRoomPageState extends State<BookRoomPage> {
  final List<Map<String, dynamic>> rooms = [
    {"id": 1, "name": "Room A", "capacity": 8},
    {"id": 2, "name": "Room B", "capacity": 12},
    {"id": 3, "name": "Room C", "capacity": 6},
    {"id": 4, "name": "Room D", "capacity": 10},
  ];

  DateTime selectedDate = DateTime.now();
  TimeOfDay? entryTime;
  TimeOfDay? exitTime;
  int selectedRoomId = -1;

  bool loading = false;

  // 🔹 Selectează data
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // 🔹 Selectează ora
  Future<void> _selectTime(BuildContext context, bool isEntry) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isEntry ? (entryTime ?? TimeOfDay.now()) : (exitTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isEntry) {
          entryTime = picked;
        } else {
          exitTime = picked;
        }
      });
    }
  }

  // 🔹 Trimite rezervarea în backend
  Future<void> _bookRoom() async {
    if (selectedRoomId == -1 || entryTime == null || exitTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a room, entry and exit time")),
      );
      return;
    }

    final userId = UserSession.userId ?? 1; // fallback dacă nu e setat
    final body = {
      "userId": userId,
      "roomId": selectedRoomId,
      "date": selectedDate.toIso8601String().split('T').first,
      "entryTime": entryTime!.format(context),
      "exitTime": exitTime!.format(context),
    };

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/reservations/room"),
        headers: {
          "Content-Type": "application/json",
          if (UserSession.token != null)
            "Authorization": "Bearer ${UserSession.token}",
        },
        body: jsonEncode(body),
      );

      setState(() => loading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room booked successfully ✅")),
        );
        Navigator.pushNamed(context, '/my_reservations');
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Access denied (403): insufficient permissions.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${response.statusCode}: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Book a Room"),
        backgroundColor: const Color(0xFF004D4D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🗓️ Data
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      "Date: ${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D4D),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🕒 Entry & Exit Time
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectTime(context, true),
                    icon: const Icon(Icons.login),
                    label: Text(entryTime == null
                        ? "Select Entry Time"
                        : "Entry: ${entryTime!.format(context)}"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D4D),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectTime(context, false),
                    icon: const Icon(Icons.logout),
                    label: Text(exitTime == null
                        ? "Select Exit Time"
                        : "Exit: ${exitTime!.format(context)}"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D4D),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Available Rooms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final bool isSelected = room["id"] == selectedRoomId;

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
                      leading: const Icon(Icons.meeting_room, color: Color(0xFF004D4D)),
                      title: Text(room["name"]),
                      subtitle: Text("Capacity: ${room["capacity"]} people"),
                      onTap: () => setState(() => selectedRoomId = room["id"]),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF004D4D))
                          : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Confirm button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _bookRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D4D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Book Room",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: Builder(builder: (context) {
        final route = ModalRoute.of(context)?.settings.name ?? '';
        final currentIndex =
        (route == '/book_room' || route.startsWith('/book_room')) ? 1 : 0;
        return BottomNavigationBar(
          selectedItemColor: const Color(0xFF004D4D),
          unselectedItemColor: Colors.grey,
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 0) Navigator.pushNamed(context, '/book_seat');
            if (index == 1) Navigator.pushNamed(context, '/book_room');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: 'Book a Seat'),
            BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'Book a Room'),
          ],
        );
      }),
    );
  }
}
