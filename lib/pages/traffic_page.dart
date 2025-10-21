import 'package:flutter/material.dart';

class TrafficPage extends StatelessWidget {
  const TrafficPage({super.key});

  // Helper to build a ListTile that navigates to a named route and closes the drawer
  Widget _navItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF004D4D)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close drawer
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Traffic"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
              // Navigation items (match bottom nav)
              _navItem(context, Icons.home, 'Home', '/dashboard'),
              _navItem(context, Icons.event_seat, 'Book My Seat', '/book_date'),
              _navItem(context, Icons.meeting_room, 'Book An Office', '/book_room'),
              _navItem(context, Icons.list_alt, 'My Bookings', '/my_bookings'),
              _navItem(context, Icons.traffic, 'Traffic', '/traffic'),
              _navItem(context, Icons.wb_sunny, 'Weather', '/weather'),
              const Divider(),
              _navItem(context, Icons.login, 'Login', '/login'),
              _navItem(context, Icons.person_add, 'Register', '/register'),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Calendar card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEFF0),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Month header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.chevron_left, color: Color(0xFF004D4D)),
                      Text('February 2022', style: TextStyle(color: Color(0xFF004D4D), fontWeight: FontWeight.w600)),
                      Icon(Icons.chevron_right, color: Color(0xFF004D4D)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Simple calendar grid placeholder
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Calendar Placeholder',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // FROM / TO pickers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FROM', style: TextStyle(letterSpacing: 1.2)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('9 h 30 m', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF004D4D))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TO', style: TextStyle(letterSpacing: 1.2)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('9 h 30 m', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF004D4D))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Address fields
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Home address:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Text('Home address...', style: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(height: 12),
                const Text('Office address:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Text('Office address...', style: TextStyle(color: Colors.black54)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006B66),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}