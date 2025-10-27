import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user_session.dart';
import 'book_seat_page.dart';

class BookLocationPage extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedTime;

  const BookLocationPage({super.key, required this.selectedDate, required this.selectedTime});

  @override
  State<BookLocationPage> createState() => _BookLocationPageState();
}

class _BookLocationPageState extends State<BookLocationPage> {
  List<BuildingDTO> buildings = [];
  List<FloorDTO> floors = [];

  BuildingDTO? selectedBuilding;
  FloorDTO? selectedFloor;

  @override
  void initState() {
    super.initState();
    fetchBuildings();
  }

  Future<void> fetchBuildings() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/buildings"),
      headers: {
        "Content-Type": "application/json",
        if (UserSession.token != null)
          "Authorization": "Bearer ${UserSession.token}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        buildings = data.map((b) => BuildingDTO.fromJson(b)).toList();
      });
    } else {
      debugPrint("Failed to load buildings: ${response.body}");
    }
  }

  Future<void> fetchFloors(int buildingId) async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/buildings/$buildingId/floors"),
      headers: {
        "Content-Type": "application/json",
        if (UserSession.token != null)
          "Authorization": "Bearer ${UserSession.token}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        floors = data.map((f) => FloorDTO.fromJson(f)).toList();
        selectedFloor = null; // reset selected floor
      });
    } else {
      debugPrint("Failed to load floors: ${response.body}");
    }
  }

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
                  DropdownButtonFormField<BuildingDTO>(
                    value: selectedBuilding,
                    decoration: InputDecoration(
                      labelText: "Building",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: buildings
                        .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(b.name),
                    ))
                        .toList(),
                    onChanged: (b) {
                      setState(() => selectedBuilding = b);
                      if (b != null) fetchFloors(b.id);
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<FloorDTO>(
                    value: selectedFloor,
                    decoration: InputDecoration(
                      labelText: "Floor",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: floors
                        .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f.name),
                    ))
                        .toList(),
                    onChanged: (f) => setState(() => selectedFloor = f),
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
                  if (selectedFloor == null) return; // ensure a floor is selected

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookSeatPage(
                        floorId: selectedFloor!.id,
                        selectedDate: widget.selectedDate,
                        entryTime: widget.selectedTime,
                        exitTime: "5 P.M.", // or any logic to select exitTime
                      ),
                    ),
                  );
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

// Models
class BuildingDTO {
  final int id;
  final String name;

  BuildingDTO({required this.id, required this.name});

  factory BuildingDTO.fromJson(Map<String, dynamic> json) {
    return BuildingDTO(id: json['id'], name: json['name']);
  }
}

class FloorDTO {
  final int id;
  final String name;

  FloorDTO({required this.id, required this.name});

  factory FloorDTO.fromJson(Map<String, dynamic> json) {
    return FloorDTO(id: json['id'], name: json['name']);
  }
}

// Bottom nav bar unchanged
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';
    final isBookingPage = route.startsWith('/book_');
    final currentIndex = (route == '/book_room' || route.startsWith('/book_room')) ? 1 : 0;
    return BottomNavigationBar(
      selectedItemColor: isBookingPage ? const Color(0xFF004D4D) : const Color(0xFF5E5F60),
      unselectedItemColor: const Color(0xFF5E5F60),
      currentIndex: currentIndex,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 0) Navigator.pushNamed(context, '/book_date');
        if (index == 1) Navigator.pushNamed(context, '/book_room');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: "Book a Seat"),
        BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Book a Room"),
      ],
    );
  }
}
