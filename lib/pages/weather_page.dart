import 'package:flutter/material.dart';
import '../models/user_session.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;
  String city = "Bucharest";
  String? temperature;
  String? description;
  String? icon;
  DateTime selectedDate = DateTime.now();

  // 🔹 Obține vremea din Visual Crossing API
  Future<void> fetchWeather() async {
    setState(() => loading = true);

    final formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final url = Uri.parse(
      'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$city/$formattedDate?unitGroup=metric&key=YOUR_API_KEY&contentType=json',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final day = data['days'][0];
      setState(() {
        temperature = "${day['temp']}°C";
        description = day['conditions'];
        icon = day['icon'];
        loading = false;
      });
    } else {
      setState(() {
        temperature = null;
        description = "Error loading data";
        icon = null;
        loading = false;
      });
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
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    final userName = UserSession.userName ?? "User";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Weather", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFDBEFF0),
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

      // 🔹 Drawer (meniu lateral)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Buton pentru selectare dată
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 3)),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                  fetchWeather();
                }
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: const Text("Select Date"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B66),
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            if (loading)
              const CircularProgressIndicator(color: Color(0xFF004D4D))
            else
              Column(
                children: [
                  if (temperature != null)
                    Text(
                      temperature!,
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B66),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    description ?? "Select a date to see the weather",
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "📍 $city - ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
          ],
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
