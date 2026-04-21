import 'package:flutter/material.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('INV-2026-001'),
            subtitle: Text('Rp 350.000'),
            trailing: Text('Paid'),
          ),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('INV-2026-002'),
            subtitle: Text('Rp 500.000'),
            trailing: Text('Pending'),
          )
        ],
      ),
    );
  }
}