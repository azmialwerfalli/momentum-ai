// lib/screens/goals/goal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:momentum_app/api/api_service.dart';
import 'package:momentum_app/models/goal.dart';
import 'package:momentum_app/models/weekly_plan.dart';
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

  Future<void> _fetchPlan() async {
    setState(() {
      _isLoadingPlan = true;
      _error = null;
    });
    
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final planData = await _apiService.generatePlanForGoal(token, widget.goal.goalId);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(widget.goal.description ?? 'No description provided.'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoadingPlan ? null : _fetchPlan,
              child: Text('Generate My Weekly Plan'),
            ),
            SizedBox(height: 16),
            if (_isLoadingPlan)
              Center(child: CircularProgressIndicator()),
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
              )
          ],
        ),
      ),
    );
  }
}