// lib/models/weekly_plan.dart
class WeeklyPlan {
  final int week;
  final String planDetails;

  WeeklyPlan({required this.week, required this.planDetails});

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(week: json['week'], planDetails: json['plan_details']);
  }
}
