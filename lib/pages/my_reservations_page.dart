import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  List<dynamic> reservations = [];
  bool isLoading = true;

  Future<void> fetchReservations() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8080/api/reservations"));
      if (response.statusCode == 200) {
        setState(() {
          reservations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load reservations");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (ctx, i) {
          final r = reservations[i];
          return ListTile(
            title: Text("Seat: ${r['seat']}"),
            subtitle: Text("Date: ${r['date']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                await http.delete(Uri.parse("http://10.0.2.2:8080/api/reservations/${r['id']}"));
                fetchReservations();
              },
            ),
          );
        },
      ),
    );
  }
}
