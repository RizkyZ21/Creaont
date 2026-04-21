import 'package:flutter/material.dart';

class DesignerDashboardScreen extends StatelessWidget {
  const DesignerDashboardScreen({super.key});

  Widget dashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Designer Dashboard'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        children: [
          dashboardCard(context, 'Orders', Icons.shopping_bag, '/order'),
          dashboardCard(context, 'Chat', Icons.chat, '/chat'),
          dashboardCard(context, 'Payment', Icons.payments, '/payment'),
          dashboardCard(context, 'Portfolio', Icons.image, '/portfolio'),
        ],
      ),
    );
  }
}