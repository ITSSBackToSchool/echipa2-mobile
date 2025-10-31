import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const kGoogleApiKey = "";

class TrafficPage extends StatefulWidget {
  const TrafficPage({super.key});

  @override
  State<TrafficPage> createState() => _TrafficPageState();
}

class _TrafficPageState extends State<TrafficPage> {
  final FlutterGooglePlacesSdk _places = FlutterGooglePlacesSdk(kGoogleApiKey);

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  LatLng? _startCoords;
  LatLng? _endCoords;

  List<AutocompletePrediction> _startPredictions = [];
  List<AutocompletePrediction> _endPredictions = [];

  bool _loading = false;
  Map<String, dynamic>? _trafficData;

  // -------------------- TRAFFIC API --------------------
  Future<void> _getTrafficInfo() async {
    if (_startCoords == null || _endCoords == null) return;

    setState(() => _loading = true);

    final uri = Uri.parse(
        "http://10.0.2.2:8080/api/traffic?origin=${_startCoords!.lat},${_startCoords!.lng}&destination=${_endCoords!.lat},${_endCoords!.lng}");

    final response = await http.get(uri);

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() => _trafficData = data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching traffic data")),
      );
    }
  }

  // -------------------- SEARCH AUTOCOMPLETE --------------------
  void _searchPlaces(String query, bool isStart) async {
    if (query.isEmpty) {
      setState(() {
        if (isStart) _startPredictions = [];
        else _endPredictions = [];
      });
      return;
    }

    try {
      final result = await _places.findAutocompletePredictions(
        query,
        countries: ["ro"],
      );

      setState(() {
        if (isStart) _startPredictions = result.predictions;
        else _endPredictions = result.predictions;
      });
    } catch (e) {
      print("Autocomplete error: $e");
    }
  }

  void _selectPrediction(AutocompletePrediction p, bool isStart) async {
    final details = await _places.fetchPlace(
      p.placeId!,
      fields: [PlaceField.Location, PlaceField.Name, PlaceField.Address],
    );

    final location = details.place?.latLng;
    if (location != null) {
      setState(() {
        if (isStart) {
          _startController.text = details.place?.address ?? p.fullText;
          _startCoords = LatLng(location.lat, location.lng);
          _startPredictions = [];
        } else {
          _endController.text = details.place?.address ?? p.fullText;
          _endCoords = LatLng(location.lat, location.lng);
          _endPredictions = [];
        }
      });
    }
  }

  // -------------------- WIDGETS --------------------
  Widget _buildLocationInput(
      String label, bool isStart, TextEditingController controller, List<AutocompletePrediction> predictions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Search $label",
            prefixIcon: Icon(isStart ? Icons.location_on : Icons.flag),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (text) => _searchPlaces(text, isStart),
        ),
        ...predictions.map((p) => ListTile(
          title: Text(p.fullText),
          leading: const Icon(Icons.location_city),
          onTap: () => _selectPrediction(p, isStart),
        )),
      ],
    );
  }

  Widget _buildTrafficCard(Map<String, dynamic> data) {
    final formatter = NumberFormat("#,##0.0");
    final trafficLevel = data["trafficLevel"] ?? "N/A";
    final color = {
      "NO_TRAFFIC": Colors.green,
      "LIGHT": Colors.lightGreen,
      "MEDIUM": Colors.orange,
      "HEAVY": Colors.redAccent,
    }[trafficLevel.toUpperCase()] ?? Colors.grey;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Traffic Summary",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(height: 12),
            _infoRow("Distance", "${formatter.format(data["distanceKm"])} km"),
            _infoRow("Normal Duration", "${data["normalDurationMin"]} minutes"),
            _infoRow("With Traffic", "${data["trafficDurationMin"]} minutes"),
            _infoRow("Delay", "${data["trafficDelayMin"]} minutes"),
            _infoRow("Level", data["trafficLevel"]),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
      ],
    ),
  );

  // -------------------- BUILD --------------------
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Traffic Checker"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLocationInput("Starting Point", true, _startController, _startPredictions),
            const SizedBox(height: 16),
            _buildLocationInput("Destination", false, _endController, _endPredictions),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _getTrafficInfo,
                icon: const Icon(Icons.traffic),
                label: const Text("Check Traffic"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const CircularProgressIndicator()
            else if (_trafficData != null)
              _buildTrafficCard(_trafficData!)
            else
              const Text(
                "Select both start and destination to check traffic.",
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}
