import 'package:creaont_flutter/screens/dashboard/customer_dashboard.dart';
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/designer_dashboard.dart';
import 'screens/order/order_screen.dart';
import 'screens/chat/chat_room_screen.dart';
import 'screens/payment/payment_status_screen.dart';
import 'utils/routes.dart';

void main() {
  runApp(const CreaontApp());
}

class CreaontApp extends StatelessWidget {
  const CreaontApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/customer-dashboard': (_) => const CustomerDashboardScreen(),
        '/dashboard': (_) => const DesignerDashboardScreen(),
        '/order': (_) => const OrderScreen(),
        '/chat': (_) => const ChatRoomScreen(),
        '/payment': (_) => const PaymentStatusScreen(),
        ...AppRoutes.routes,
      },
    );
  }
}
