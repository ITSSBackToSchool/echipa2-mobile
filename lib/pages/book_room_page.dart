import 'package:flutter/material.dart';

class BookRoomPage extends StatelessWidget {
  const BookRoomPage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> rooms = [
      {"name": "Room A", "capacity": 8},
      {"name": "Room B", "capacity": 12},
      {"name": "Room C", "capacity": 6},
      {"name": "Room D", "capacity": 10},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Room"),
        backgroundColor: const Color(0xFF004D4D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];


            final String roomName = room["name"] ?? "Unnamed Room";
            final int capacity = room["capacity"] ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.meeting_room, color: Color(0xFF004D4D)),
                title: Text(roomName),
                subtitle: Text("Capacity: $capacity people"),
                trailing: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/book_seat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D4D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Book"),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
