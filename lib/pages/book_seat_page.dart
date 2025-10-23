import 'package:flutter/material.dart';

class BookSeatPage extends StatefulWidget {
  const BookSeatPage({super.key});

  @override
  State<BookSeatPage> createState() => _BookSeatPageState();
}

class _BookSeatPageState extends State<BookSeatPage> {
  int selectedSeat = -1;
  final int rows = 6;
  final int columns = 8;

  TimeOfDay? entryTime;
  TimeOfDay? exitTime;

  Future<void> _selectTime(BuildContext context, bool isEntry) async {
    final TimeOfDay? picked = await showTimePicker(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📅 Date: 12 Oct 2025"),
            const Text("🏢 Building: Tower 1"),
            const SizedBox(height: 16),

            // 🕒 Entry Time
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
              "Choose Your Seat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 🪑 Seat grid
            Expanded(
              child: GridView.builder(
                itemCount: rows * columns,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final bool isSelected = index == selectedSeat;
                  final bool isReserved = index % 7 == 0; // simulate reserved seats
                  return GestureDetector(
                    onTap: () {
                      if (!isReserved) {
                        setState(() => selectedSeat = index);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isReserved
                            ? Colors.grey.shade300
                            : (isSelected
                            ? const Color(0xFF004D4D)
                            : const Color(0xFFE6F2F2)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Confirm button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedSeat == -1 || entryTime == null || exitTime == null
                    ? null
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Seat booked from ${entryTime!.format(context)} to ${exitTime!.format(context)} ✅",
                      ),
                    ),
                  );
                  Navigator.pushNamed(context, '/dashboard');
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
      selectedItemColor:
      isBookingPage ? const Color(0xFF004D4D) : const Color(0xFF5E5F60),
      unselectedItemColor: const Color(0xFF5E5F60),
      currentIndex: currentIndex,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 0) Navigator.pushNamed(context, '/book_seat');
        if (index == 1) Navigator.pushNamed(context, '/book_room');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: "Book a Seat"),
        BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Book a Room"),
      ],
    );
  }
}
