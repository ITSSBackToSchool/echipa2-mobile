import 'package:flutter/material.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final List<Map<String, String>> reservations = [
    {'dateLabel': 'Today', 'date': '25-10-2025'},
    {'dateLabel': 'Tomorrow', 'date': '26-10-2025'},
    {'dateLabel': '24th October', 'date': '24-10-2025'},
    {'dateLabel': '25th October', 'date': '25-10-2025'},
  ];

  Future<bool?> _confirmCancel(BuildContext ctx) {
    return showDialog<bool>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('Are you sure you want to delete?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D4D),
              foregroundColor: Colors.white,
            ),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D4D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFFDBEFF0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: reservations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (ctx, i) {
                  final r = reservations[i];
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F2F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r['dateLabel'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006B66),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Edit', style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      final confirmed = await _confirmCancel(context);
                                      if (confirmed == true) {
                                        // For now just show snack; you can remove from list if persistent state is desired
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking deleted')));
                                      }
                                    },
                                    child: const Icon(Icons.delete_outline, color: Colors.black54),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
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