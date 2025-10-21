import 'package:flutter/material.dart';

class BookDatePage extends StatefulWidget {
  const BookDatePage({super.key});

  @override
  State<BookDatePage> createState() => _BookDatePageState();
}

class _BookDatePageState extends State<BookDatePage> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = "9 A.M.";

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
            const SizedBox(height: 20),
            const Text(
              "Choose Date and Time",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2F2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3))
                ],
              ),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                onDateChanged: (value) => setState(() => selectedDate = value),
              ),
            ),
            const SizedBox(height: 20),
            const Text("ENTRY TIME", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(selectedTime,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/book_location');
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
    final route = ModalRoute.of(context)?.settings.name ?? '';
    final isBookingPage = route.startsWith('/book_');
    final currentIndex = (route == '/book_room' || route.startsWith('/book_room')) ? 1 : 0;
    return BottomNavigationBar(
      selectedItemColor: isBookingPage ? const Color(0xFF004D4D) : Colors.grey,
      unselectedItemColor: Colors.grey,
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
