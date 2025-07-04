// lib/screens/goals/goals_list_screen.dart
import 'package:flutter/material.dart';
import 'package:momentum_app/api/api_service.dart';
import 'package:momentum_app/models/goal.dart';
import 'package:momentum_app/screens/goals/goal_detail_screen.dart'; // We'll create this next
import 'package:momentum_app/state/auth_provider.dart';
import 'package:provider/provider.dart';

class GoalsListScreen extends StatefulWidget {
  const GoalsListScreen({super.key});

  @override
  State<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends State<GoalsListScreen> {
  late Future<List<Goal>> _goalsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    _goalsFuture = _apiService
        .getGoals(token!)
        .then((data) => data.map((item) => Goal.fromJson(item)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Goals')),
      body: FutureBuilder<List<Goal>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No goals yet. Create one!'));
          }

          final goals = snapshot.data!;
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return ListTile(
                title: Text(goal.title),
                subtitle: Text(goal.description ?? ''),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GoalDetailScreen(goal: goal),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
