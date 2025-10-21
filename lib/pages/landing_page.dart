import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset('assets/illustration.png', height: 220),
            const SizedBox(height: 30),
            const Text(
              "Get things done with OffiSeat",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D4D),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Book your seat, room or workspace easily in your company hub.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D4D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Get Started",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text("Already have an account? Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}

