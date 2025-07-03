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
