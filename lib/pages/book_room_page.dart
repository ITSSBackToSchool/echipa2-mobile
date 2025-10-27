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
  List<Map<String, dynamic>> rooms = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay? entryTime;
  TimeOfDay? exitTime;
  int selectedRoomId = -1;
  bool loading = false;
  bool loadingRooms = false;

  // 🔹 Fetch rooms from backend
  Future<void> _fetchRooms() async {
    setState(() => loadingRooms = true);

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/api/rooms"),
        headers: {
          "Content-Type": "application/json",
          if (UserSession.token != null)
            "Authorization": "Bearer ${UserSession.token}",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          rooms = data.map((room) {
            return {
              "id": room["id"],
              "name": room["name"],       // room name
              "floorName": room["floorName"], // floor
              "buildingName": room["buildingName"], // building
            };
          }).toList();
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

  // 🔹 Select date
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // 🔹 Select entry/exit time
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

  // ✅ FIXED: Properly format TimeOfDay to "HH:mm:ss"
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
  }

  // 🔹 Book room
  Future<void> _bookRoom() async {
    if (selectedRoomId == -1 || entryTime == null || exitTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a room, entry and exit time")),
      );
      return;
    }

    final userId = UserSession.userId ?? 1;

    // ✅ FIXED: Send correctly formatted times to match backend LocalTime
    final body = {
      "userId": userId,
      "roomIds": selectedRoomId,
      "reservationDate": selectedDate.toIso8601String().split('T').first,
      "startTime": _formatTimeOfDay(entryTime!), // ✅ FIXED
      "endTime": _formatTimeOfDay(exitTime!),     // ✅ FIXED
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
        Navigator.pushNamed(context, '/dashboard');
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
  void initState() {
    super.initState();
    _fetchRooms();
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
            // 🗓️ Date picker
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
              child: loadingRooms
                  ? const Center(child: CircularProgressIndicator())
                  : rooms.isEmpty
                  ? const Center(child: Text("No rooms available"))
                  : ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final bool isSelected = room["id"] == selectedRoomId;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF004D4D)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.meeting_room, color: Color(0xFF004D4D)),
                      title: Text(room["name"] ?? ""), // room name
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (room["floorName"] != null) Text("Floor: ${room["floorName"]}"),
                          if (room["buildingName"] != null) Text("Building: ${room["buildingName"]}")
                        ],
                      ),
                      trailing: selectedRoomId == room["id"]
                          ? const Icon(Icons.check_circle, color: Color(0xFF004D4D))
                          : null,
                      onTap: () => setState(() => selectedRoomId = room["id"]),
                    ),


                  );
                },
              ),
            ),

            const SizedBox(height: 12),

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
            if (index == 1) Navigator.pushNamed;

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
