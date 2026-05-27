import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Order Detail"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),

              child: Image.network("https://picsum.photos/400/200"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Mobile App UI/UX Design",

              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Designer : Alex Designer",

              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 20),

            const Text(
              "Order Description",

              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Modern UI design for mobile application including onboarding, dashboard and profile page.",

              style: TextStyle(color: Colors.white70),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text("Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
