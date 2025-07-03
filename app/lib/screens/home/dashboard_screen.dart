// lib/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:momentum_app/state/auth_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the provider to call the logout function
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Momentum'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          )
        ],
      ),
      body: Center(
        child: Text('Welcome! This is your dashboard.'),
      ),
    );
  }
}