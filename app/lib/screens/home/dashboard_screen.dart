// lib/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momentum_app/api/api_service.dart';
import 'package:momentum_app/models/dashboard_habit.dart';
import 'package:momentum_app/state/auth_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<DashboardHabit>> _dashboardFuture;
  final ApiService _apiService = ApiService();
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch the data when the widget is first created
    _fetchDashboardData();
  }

  void _fetchDashboardData() {
    // Get the token from AuthProvider
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      setState(() {
        _dashboardFuture = _apiService
            .getDashboard(token, _selectedDate)
            .then(
              (data) =>
                  data.map((item) => DashboardHabit.fromJson(item)).toList(),
            );
      });
    }
  }

  Future<void> _toggleHabitCompletion(DashboardHabit habit) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    // For now, we only handle checking the box, not unchecking
    if (!habit.isCompleted) {
      try {
        await _apiService.logProgress(token, habit.habitId, _selectedDate);
        // Refresh the dashboard data to show the change
        _fetchDashboardData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update habit: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Today - ${DateFormat.yMMMd().format(_selectedDate)}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DashboardHabit>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No habits found for today. Add one!'));
          }

          // If we have data, build the list
          final habits = snapshot.data!;
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(habit.title),
                  trailing: Checkbox(
                    value: habit.isCompleted,
                    onChanged: (bool? value) {
                      _toggleHabitCompletion(habit);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
