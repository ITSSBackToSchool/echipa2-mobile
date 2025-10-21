import 'package:flutter/material.dart';

class BookLocationPage extends StatefulWidget {
  const BookLocationPage({super.key});

  @override
  State<BookLocationPage> createState() => _BookLocationPageState();
}

class _BookLocationPageState extends State<BookLocationPage> {
  String? selectedBuilding;
  String? selectedFloor;

  final List<String> buildings = ["Anywhere", "Tower 1", "Tower 2"];
  final List<String> floors = ["Anywhere", "Ground", "Floor 1", "Floor 2"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book your seat"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: const _BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text("Date: 12 Oct 2025"),
            const SizedBox(height: 8),
            const Text("Time: 9 A.M."),
            const SizedBox(height: 20),
            const Text(
              "Choose Building and Floor",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedBuilding,
                    decoration: InputDecoration(
                      labelText: "Building",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: buildings
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedBuilding = v),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedFloor,
                    decoration: InputDecoration(
                      labelText: "Floor",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: floors
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedFloor = v),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/book_seat');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D4D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Continue",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFF004D4D),
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: "Seats"),
        BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Rooms"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "My Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.traffic), label: "Traffic"),
      ],
    );
  }
}
