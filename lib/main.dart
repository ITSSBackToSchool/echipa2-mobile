import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/book_location_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/book_date_page.dart';
import 'pages/book_room_page.dart';
import 'pages/book_seat_page.dart';
import 'pages/traffic_page.dart';
import 'pages/my_reservations_page.dart';
import 'pages/weather_page.dart';

void main() {
  // Set system status bar color and icons to match app design
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF323232),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(const OffiSeatApp());
}

class OffiSeatApp extends StatelessWidget {
  const OffiSeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OffiSeat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D4D)),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
         '/book_date': (context) => const BookDatePage(),
        // '/book_location': (context) => const BookLocationPage(),
        '/book_room': (context) => const BookRoomPage(),
        '/book_seat': (context) => const BookDatePage(),
        '/traffic': (context) => const TrafficPage(),
        '/my_reservations': (context) => const MyReservationsPage(),
        '/weather': (context) => const WeatherPage(),
      },
    );
  }
}


