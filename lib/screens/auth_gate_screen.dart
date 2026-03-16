import 'package:flutter/material.dart';
import 'package:mini_e_commerce/screens/home_screen.dart';
import 'package:mini_e_commerce/screens/login_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isInitialized || authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
