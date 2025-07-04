// lib/api/api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // The base URL of our FastAPI server
  // For Android Emulator, use 10.0.2.2 to connect to your local machine's localhost
  // For iOS Simulator, use 'localhost' or '127.0.0.1'
  // For a real device, this would be your server's public IP address
  // static const String _baseUrl = 'http://10.0.2.2:8000';
  static const String _baseUrl = 'http://127.0.0.1:8000';

  // --- AUTHENTICATION ---

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );

    // Helper function to handle response
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    // FastAPI's OAuth2PasswordRequestForm expects form data, not JSON
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email, // Remember we use email for the username field
        'password': password,
      },
    );

    return _handleResponse(response);
  }

  // --- DASHBOARD & PROGRESS ---

  // Note: The token is now required for these methods
  Future<List<dynamic>> getDashboard(String token, DateTime date) async {
    // Format the date to YYYY-MM-DD
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('$_baseUrl/dashboard/$formattedDate');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Send the auth token
      },
    );

    // We are expecting a list, so handle it directly
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(responseBody['detail'] ?? 'Failed to load dashboard');
    }
  }

  Future<Map<String, dynamic>> logProgress(
    String token,
    String habitId,
    DateTime date,
  ) async {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('$_baseUrl/progress-logs');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'habit_id': habitId, 'log_date': formattedDate}),
    );

    return _handleResponse(response);
  }

  // ... Missed Habit ...

  Future<Map<String, dynamic>> getMissedHabitFeedback(
    String token,
    String habitId,
    String reason,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/feedback/missed-habit',
    ); // URL no longer needs the reason
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Send a JSON body instead of a query parameter
      body: json.encode({'habit_id': habitId, 'reason': reason}),
    );

    return _handleResponse(response);
  }
  // --- GOALS ---

  Future<List<dynamic>> getGoals(String token) async {
    final url = Uri.parse('$_baseUrl/goals');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(responseBody['detail'] ?? 'Failed to load goals');
    }
  }

  Future<Map<String, dynamic>> generatePlanForGoal(
    String token,
    String goalId,
  ) async {
    final url = Uri.parse('$_baseUrl/goals/$goalId/generate-plan');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  // ... Generate GOALS and Habits ...

  Future<Map<String, dynamic>> createGoal(
    String token, {
    required String title,
    String? description,
    required String goalType, // e.g., 'TARGET_VALUE'
    double? targetValue,
    String? targetUnit,
    String? targetDate, // YYYY-MM-DD format
  }) async {
    final url = Uri.parse('$_baseUrl/goals');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'goal_type': goalType,
        'target_value': targetValue,
        'target_unit': targetUnit,
        'target_date': targetDate,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createHabit(
    String token, {
    required String title,
    required String goalId,
  }) async {
    final url = Uri.parse('$_baseUrl/habits');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'title': title, 'goal_id': goalId}),
    );
    return _handleResponse(response);
  }

  // --- Goal Habits  ---
  Future<List<dynamic>> getHabitsForGoal(String token, String goalId) async {
    final url = Uri.parse('$_baseUrl/habits/by_goal/$goalId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load habits');
    }
  }

  // --- HELPER FUNCTION ---

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> responseBody = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Successful response
      return responseBody;
    } else {
      // Unsuccessful response, throw an exception with the detail message from the server
      throw Exception(responseBody['detail'] ?? 'An unknown error occurred');
    }
  }
}
