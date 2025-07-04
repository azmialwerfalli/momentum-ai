// lib/screens/goals/add_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:momentum_app/api/api_service.dart';
import 'package:momentum_app/state/auth_provider.dart';
import 'package:provider/provider.dart';

class AddHabitScreen extends StatefulWidget {
  final String goalId;
  const AddHabitScreen({super.key, required this.goalId});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _submitHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      try {
        await _apiService.createHabit(
          token!,
          title: _titleController.text,
          goalId: widget.goalId,
        );
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        // Handle error
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Habit Title (e.g., Daily Run)'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitHabit,
                child: _isLoading ? CircularProgressIndicator() : Text('Save Habit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}