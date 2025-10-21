import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, String>> reservations = [
    {
      "type": "Desk Booking",
      "details": "Building T1 • Floor 2 • Quiet Zone, Seat #1-2",
      "date": "18-10-2025",
      "time": "09:00 - 17:00"
    },
    {
      "type": "Desk Booking",
      "details": "Building T1 • Floor 2 • Quiet Zone, Seat #1-2",
      "date": "18-10-2025",
      "time": "09:00 - 17:00"
    },
    {
      "type": "Meeting Room",
      "details": "Building T1 • Floor 2 • Conference Room 65",
      "date": "18-10-2025",
      "time": "09:00 - 17:00"
    },
  ];

  // Helper to build a ListTile that navigates to a named route and closes the drawer
  Widget _navItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF004D4D)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close drawer
        // Avoid pushing the same route repeatedly: if already on dashboard and route is '/dashboard', just pop
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("OffiSeat", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFDBEFF0),
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F2F2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('OffiSeat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D4D))),
                    SizedBox(height: 6),
                    Text('Navigate to a page', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              // Navigation items (reduced)
              _navItem(context, Icons.home, 'Home', '/dashboard'),
              _navItem(context, Icons.list_alt, 'My Bookings', '/my_reservations'),
              _navItem(context, Icons.wb_sunny, 'Weather', '/weather'),
              _navItem(context, Icons.traffic, 'Traffic', '/traffic'),
              const Divider(),
              // Log out
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF004D4D)),
                title: const Text('Log out'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement logout action: navigate to login and clear stack
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 Welcome section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/illustration.png',
                  height: 90,
                  errorBuilder: (_, __, ___) => const Icon(Icons.work, size: 80, color: Color(0xFF004D4D)),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    "Welcome back,\nMarcel!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF004D4D),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ⚡ Quick Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2F2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Book your workspace or seat for today or upcoming days",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/book_date'),
                          icon: const Icon(Icons.event_seat),
                          label: const Text("Book a Seat"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D4D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/book_room'),
                          icon: const Icon(Icons.meeting_room_outlined),
                          label: const Text("Book a Room"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D4D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📅 Reservations section
            const Text(
              "Your Reservations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Upcoming bookings and reservations",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Color(0xFFDDDDDD),
              thickness: 1,
              height: 16,
            ),

            // List of reservations
            Column(
              children: reservations.asMap().entries.map((entry) {
                final index = entry.key;
                final res = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F2F2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_note, color: Color(0xFF004D4D)),
                          const SizedBox(width: 8),
                          Text(
                            res["type"] ?? "Booking",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(res["details"] ?? "",
                          style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(res["date"] ?? ""),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(res["time"] ?? ""),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF004D4D)),
                            ),
                            child: const Text(
                              "Modify",
                              style: TextStyle(color: Color(0xFF004D4D)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Are you sure you want to delete?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF004D4D),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF004D4D),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                setState(() {
                                  reservations.removeAt(index);
                                });
                              }
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text("Cancel"),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      // 🔹 Bottom Navigation Bar (only Book a Seat and Book a Room)
      bottomNavigationBar: Builder(builder: (context) {
        final route = ModalRoute.of(context)?.settings.name ?? '';
        final isBookingPage = route.startsWith('/book_');
        final currentIndex = (route == '/book_room' || route.startsWith('/book_room')) ? 1 : 0;
        return BottomNavigationBar(
          selectedItemColor: isBookingPage ? const Color(0xFF004D4D) : Colors.grey,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 0) Navigator.pushNamed(context, '/book_date');
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
