import 'package:flutter/material.dart';

import '../screens/auth/register_screen.dart';
import '../screens/dashboard/customer_dashboard.dart';
import '../screens/profile/customer_profile_screen.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/register': (_) => const RegisterScreen(),
    '/customer-dashboard': (_) => const CustomerDashboardScreen(),
    '/customer-profile': (_) => const CustomerProfileScreen(),
  };
}
