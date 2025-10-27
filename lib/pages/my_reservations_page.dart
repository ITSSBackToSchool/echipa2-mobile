import 'dart:io';

import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';
import '../services/reservation_api.dart';
import '../models/reservation.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    print("------------------------------------------------------------------------");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchReservations();
    });
  }

  Future<void> fetchReservations() async {
    final userId = UserSession.userId;
    if (userId != null) {
      final res = await ApiService.getUserReservations(userId);
      if (res != null) {
        setState(() {
          reservations = res
              .map((r) => {
            "status": r["status"],
            "id": r["id"],
            "type": r["seatNumber"] != null ? "Desk Booking" : "Meeting Room",
            "details": r["roomName"] != null
                ? "${r["buildingName"]} • ${r["floorName"]} • ${r["roomName"]}"
                : "${r["buildingName"]} • ${r["floorName"]} • Seat ${r["seatNumber"]}",
            "date": r["reservationDate"] ?? "",
            "time": "${r["startTime"] ?? ""} - ${r["endTime"] ?? ""}"
          })
              .toList();

          // 🔹 Sort so that non-cancelled reservations appear first
          reservations.sort((a, b) {
            if (a["status"] == "CANCELLED" && b["status"] != "CANCELLED") return 1;
            if (a["status"] != "CANCELLED" && b["status"] == "CANCELLED") return -1;
            return 0;
          });

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  Widget _navItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF004D4D)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = UserSession.userName ?? "User";

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFDBEFF0),
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // <-- currently false
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),

      // 🔹 Drawer lateral
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFFE6F2F2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'OffiSeat',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D4D)),
                    ),
                    const SizedBox(height: 6),
                    Text('Logged in as $userName', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              _navItem(context, Icons.home, 'Home', '/dashboard'),
              _navItem(context, Icons.list_alt, 'My Bookings', '/my_reservations'),
              _navItem(context, Icons.wb_sunny, 'Weather', '/weather'),
              _navItem(context, Icons.traffic, 'Traffic', '/traffic'),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF004D4D)),
                title: const Text('Log out'),
                onTap: () {
                  UserSession.clear();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),

      // 🔹 Conținut principal
      body: RefreshIndicator(
        onRefresh: fetchReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Column(
                children: isLoading
                    ? [const Center(child: CircularProgressIndicator())]
                    : reservations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final res = entry.value;
                  final isCancelled = res["status"] == "CANCELLED"; // <-- check status

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F2F2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
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
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(res["details"] ?? "", style: const TextStyle(color: Colors.black87)),
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
                        if (!isCancelled) const SizedBox(height: 14),
                        if (!isCancelled)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF004D4D)),
                                ),
                                child: const Text("Modify",
                                    style: TextStyle(color: Color(0xFF004D4D))),
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
                                    try {
                                      await ReservationApi.cancelReservation(reservations[index]['id']);
                                      setState(() {
                                        reservations.removeAt(index);
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Reservation canceled successfully')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to cancel reservation')),
                                      );
                                    }
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
                          ),
                        if (isCancelled)
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Text(
                              'Cancelled',
                              style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            ],
          ),
        ),
      ),
      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: Builder(
        builder: (context) {
          final route = ModalRoute.of(context)?.settings.name ?? '';
          final isBookingPage = route.startsWith('/book_');
          final currentIndex =
          (route == '/book_room' || route.startsWith('/book_room')) ? 1 : 0;
          return BottomNavigationBar(
            selectedItemColor:
            isBookingPage ? const Color(0xFF004D4D) : const Color(0xFF5E5F60),
            unselectedItemColor: const Color(0xFF5E5F60),
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
        },
      ),
    );
  }
}
