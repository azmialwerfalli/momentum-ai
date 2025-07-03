// lib/main.dart
import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MomentumApp());
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum AI',
      theme: ThemeData(
        primarySwatch: Colors.teal, // A nice theme to start with
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // For now, we always start at the login screen.
      // Later, we'll add logic to check if the user is already logged in.
      home: LoginScreen(),
    );
  }
}
