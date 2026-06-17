import 'package:flutter/material.dart';

class RescueScreen extends StatelessWidget {
  final String alertId;

  const RescueScreen({
    super.key,
    required this.alertId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Rescue",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Container(
              height: 320,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Rescue in Progress",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Waiting for live location...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const Spacer(),

            SizedBox(
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {},

                icon: const Icon(Icons.navigation),

                label: const Text(
                  "Navigate",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}