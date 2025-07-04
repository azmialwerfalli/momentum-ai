// lib/models/goal.dart
class Goal {
  final String goalId;
  final String title;
  final String? description;
  // Add other fields from your API if you need them

  Goal({
    required this.goalId,
    required this.title,
    this.description,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      goalId: json['goal_id'],
      title: json['title'],
      description: json['description'],
    );
  }
}