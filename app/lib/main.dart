// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'package:momentum_app/screens/home/dashboard_screen.dart'; // Import dashboard
import 'package:momentum_app/state/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MomentumApp());
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
       title: 'Momentum AI',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // For now, we always start at the login screen.
        // Later, we'll add logic to check if the user is already logged in.
        home: AuthWrapper(),
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    // Based on authentication status, show the correct screen
    if (authProvider.isAuthenticated) {
      return DashboardScreen(); // We will create this placeholder next
    } else {
      return LoginScreen();
    }
  }
}