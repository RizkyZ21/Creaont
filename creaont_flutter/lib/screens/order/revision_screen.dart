import 'package:flutter/material.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),

      appBar: AppBar(title: const Text("Revision")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: controller,

              maxLines: 5,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Write revision request...",

                filled: true,

                fillColor: Colors.white10,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Revision Sent")),
                  );
                },

                child: const Text("Send Revision"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
