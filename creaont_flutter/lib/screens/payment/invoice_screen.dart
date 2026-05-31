import 'package:flutter/material.dart';

import 'payment_status_screen.dart';

class InvoiceScreen extends StatefulWidget {
  final String title;
  final String price;

  const InvoiceScreen({super.key, required this.title, required this.price});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String paymentMethod = "QRIS";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        title: const Text("Invoice", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Detail Pesanan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Layanan",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        widget.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        widget.price,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Metode Pembayaran",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  RadioListTile<String>(
                    value: "QRIS",
                    groupValue: paymentMethod,
                    activeColor: Colors.purple,
                    title: const Text(
                      "QRIS",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),

                  RadioListTile<String>(
                    value: "DANA",
                    groupValue: paymentMethod,
                    activeColor: Colors.purple,
                    title: const Text(
                      "DANA",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),

                  RadioListTile<String>(
                    value: "GoPay",
                    groupValue: paymentMethod,
                    activeColor: Colors.purple,
                    title: const Text(
                      "GoPay",
                      style: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),

                  RadioListTile<String>(
                    value: "Bank Mandiri",
                    groupValue: paymentMethod,
                    activeColor: Colors.purple,
                    title: const Text(
                      "Bank Mandiri",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      "Virtual Account",
                      style: TextStyle(color: Colors.white54),
                    ),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentStatusScreen(
                        title: widget.title,
                        price: widget.price,
                        paymentMethod: paymentMethod,
                      ),
                    ),
                  );
                },
                child: const Text("Bayar Sekarang"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
