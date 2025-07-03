// lib/models/dashboard_habit.dart
class DashboardHabit {
  final String habitId;
  final String title;
  bool isCompleted;

  DashboardHabit({
    required this.habitId,
    required this.title,
    required this.isCompleted,
  });

  // A 'factory constructor' to create a DashboardHabit from the JSON we get from the API
  factory DashboardHabit.fromJson(Map<String, dynamic> json) {
    return DashboardHabit(
      habitId: json['habit_id'],
      title: json['title'],
      isCompleted: json['is_completed'],
    );
  }
}
