// lib/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momentum_app/api/api_service.dart';
import 'package:momentum_app/models/dashboard_habit.dart';
import 'package:momentum_app/screens/goals/goals_list_screen.dart';
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

  Future<void> _handleMissedHabit(DashboardHabit habit) async {
    // 1. Show a dialog to ask for the reason
    final reason = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Why was this habit missed?'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'busy');
              },
              child: const Text('I was too busy'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'asleep');
              },
              child: const Text('I was asleep'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'unmotivated');
              },
              child: const Text('Felt unmotivated'),
            ),
          ],
        );
      },
    );

    // 2. If the user selected a reason, call the API
    if (reason != null) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) return;

      try {
        final result = await _apiService.getMissedHabitFeedback(
          token,
          habit.habitId,
          reason,
        );
        final feedback = result['feedback'];

        // 3. Show the AI feedback in a SnackBar or another dialog
        if (mounted) {
          // Check if the widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Coach says: $feedback'),
              duration: Duration(seconds: 5), // Make it a bit longer
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to get feedback: $e')));
        }
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
                  // The onTap for the ListTile itself
                  onTap: () {
                    // We can use the main tap area for toggling completion too
                    _toggleHabitCompletion(habit);
                  },
                  // The NEW long press gesture
                  onLongPress: () {
                    // If a habit isn't done, you can mark it as missed
                    if (!habit.isCompleted) {
                      _handleMissedHabit(habit);
                    }
                  },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => GoalsListScreen()));
        },
        tooltip: 'My Goals',
        child: Icon(Icons.track_changes),
      ),
    );
  }
}
