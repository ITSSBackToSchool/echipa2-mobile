import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey = "9T8J8VXTPVA9LL9DWKQ58E668";
  final TextEditingController _controller = TextEditingController(text: "Bucharest");

  String city = "Bucharest";
  String? selectedDate;
  double? temperature;
  String? conditions;
  String? description;
  bool loading = false;
  String? error;


  Future<void> fetchWeather(String cityName, String date) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final url = Uri.parse(
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$cityName/$date?unitGroup=metric&key=$apiKey&contentType=json",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final day = data['days'][0]; // datele pentru ziua selectată
        setState(() {
          city = data['address'];
          temperature = day['temp'];
          conditions = day['conditions'];
          description = day['description'];
        });
      } else {
        setState(() => error = "City not found ❌");
      }
    } catch (e) {
      setState(() => error = "Error: $e");
    }

    setState(() => loading = false);
  }

  // 🔹 Calendar picker pentru selectarea unei date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );

    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        selectedDate = formattedDate;
      });
      fetchWeather(_controller.text.trim(), formattedDate);
    }
  }

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    selectedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    fetchWeather(city, selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather"),
        backgroundColor: const Color(0xFF004D4D),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Căutare oraș
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter city name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty && selectedDate != null) {
                      fetchWeather(_controller.text.trim(), selectedDate!);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Selector de dată
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF004D4D)),
                const SizedBox(width: 8),
                Text(
                  selectedDate ?? "Select a date",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D4D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Choose Date"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            if (loading)
              const CircularProgressIndicator()
            else if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red))
            else if (temperature != null)
                Column(
                  children: [
                    Text(
                      city,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D4D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${temperature!.toStringAsFixed(1)} °C",
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D4D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      conditions ?? "",
                      style: const TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
