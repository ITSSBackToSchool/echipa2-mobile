import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';
import '../services/reservation_api.dart';

enum ReservationFilter { next, done, cancelled }

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;

  ReservationFilter selectedFilter = ReservationFilter.next;

  @override
  void initState() {
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
            "type":
            r["seatNumber"] != null ? "Desk Booking" : "Meeting Room",
            "details": r["roomName"] != null
                ? "${r["buildingName"]} • ${r["floorName"]} • ${r["roomName"]}"
                : "${r["buildingName"]} • ${r["floorName"]} • Seat ${r["seatNumber"]}",
            "date": r["reservationDate"] ?? "",
            "time": "${r["startTime"] ?? ""} - ${r["endTime"] ?? ""}"
          })
              .toList();

          // 🔹 Sort ascending by date
          reservations.sort((a, b) {
            final dateA = DateTime.tryParse(a["date"] ?? "") ?? DateTime.now();
            final dateB = DateTime.tryParse(b["date"] ?? "") ?? DateTime.now();
            return dateA.compareTo(dateB);
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

  Widget filterButton(String label, ReservationFilter filter) {
    final bool isSelected = selectedFilter == filter;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF006B66) : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }

  Widget reservationCard(Map<String, dynamic> res) {
    final isCancelled = res["status"] == "CANCELLED";
    final date = DateTime.tryParse(res["date"] ?? "") ?? DateTime.now();
    final isDone = !isCancelled && date.isBefore(DateTime.now());

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
              Icon(
                res["type"] == "Desk Booking"
                    ? Icons.event_seat
                    : Icons.meeting_room_outlined,
                color: const Color(0xFF004D4D),
              ),
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
          if (!isCancelled && !isDone) const SizedBox(height: 14),
          if (!isCancelled && !isDone)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

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
                        await ReservationApi.cancelReservation(res["id"]);
                        setState(() {
                          reservations.remove(res);
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
          if (isCancelled || isDone)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                isCancelled ? 'Cancelled' : 'Done',
                style: TextStyle(
                    color: isCancelled ? Colors.red[700] : Colors.green[700],
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = UserSession.userName ?? "User";

    // 🔹 Filter reservations based on selected tab
    final now = DateTime.now();
    List<Map<String, dynamic>> filteredReservations = reservations.where((r) {
      final date = DateTime.tryParse(r["date"] ?? "") ?? now;

      switch (selectedFilter) {
        case ReservationFilter.next:
          return r["status"] != "CANCELLED" && date.isAfter(now);
        case ReservationFilter.done:
          return r["status"] != "CANCELLED" && date.isBefore(now);
        case ReservationFilter.cancelled:
          return r["status"] == "CANCELLED";
      }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "My Bookings",
        ),
        backgroundColor: const Color(0xFFDBEFF0),
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
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
      body: RefreshIndicator(
        onRefresh: fetchReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Filter tabs
              Row(
                children: [
                  filterButton("Next", ReservationFilter.next),
                  const SizedBox(width: 10),
                  filterButton("Done", ReservationFilter.done),
                  const SizedBox(width: 10),
                  filterButton("Cancelled", ReservationFilter.cancelled),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Reservations
              Column(
                children: isLoading
                    ? [const Center(child: CircularProgressIndicator())]
                    : filteredReservations.map((res) => reservationCard(res)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
