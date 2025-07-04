// lib/screens/goals/goal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:momentum_app/api/api_service.dart';
// New imports
import 'package:momentum_app/models/dashboard_habit.dart'; // We can reuse this model
import 'package:momentum_app/models/goal.dart';
import 'package:momentum_app/models/weekly_plan.dart';
import 'package:momentum_app/screens/goals/add_habit_screen.dart';
import 'package:momentum_app/state/auth_provider.dart';
import 'package:provider/provider.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final ApiService _apiService = ApiService();
  WeeklyPlan? _weeklyPlan;
  bool _isLoadingPlan = false;
  String? _error;
  late Future<List<DashboardHabit>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _refreshHabits();
  }

  void _refreshHabits() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    setState(() {
      // This API call doesn't exist yet, we need to add it!
      // Let's assume we have _apiService.getHabitsForGoal(token, widget.goal.goalId)
      // For now, let's create it in the ApiService.
      // In ApiService, getHabitsForGoal will call GET /habits/by_goal/{goal_id}
      _habitsFuture = _apiService
          .getHabitsForGoal(token!, widget.goal.goalId)
          .then(
            (data) =>
                data.map((item) => DashboardHabit.fromJson(item)).toList(),
          );
    });
  }

  Future<void> _fetchPlan() async {
    setState(() {
      _isLoadingPlan = true;
      _error = null;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final planData = await _apiService.generatePlanForGoal(
        token,
        widget.goal.goalId,
      );
      setState(() {
        _weeklyPlan = WeeklyPlan.fromJson(planData);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingPlan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.goal.title)),
      // Add a FAB to add new habits
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => AddHabitScreen(goalId: widget.goal.goalId),
            ),
          );
          if (result == true) {
            _refreshHabits();
          }
        },
        tooltip: 'Add Habit',
        child: Icon(Icons.add_task),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // To prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(widget.goal.description ?? 'No description.'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoadingPlan ? null : _fetchPlan,
                child: Text('Generate My Weekly Plan'),
              ),
              SizedBox(height: 16),
              if (_isLoadingPlan) Center(child: CircularProgressIndicator()),
              if (_error != null)
                Text('Error: $_error', style: TextStyle(color: Colors.red)),
              if (_weeklyPlan != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan for Week ${_weeklyPlan!.week}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(_weeklyPlan!.planDetails),
                      ],
                    ),
                  ),
                ),
              // NEW: Section for Habits
              SizedBox(height: 24),
              Text(
                'Associated Habits',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              FutureBuilder<List<DashboardHabit>>(
                future: _habitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No habits yet. Add one!'));
                  }
                  final habits = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true, // Important inside a Column
                    physics: NeverScrollableScrollPhysics(), // Also important
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(title: Text(habits[index].title)),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
