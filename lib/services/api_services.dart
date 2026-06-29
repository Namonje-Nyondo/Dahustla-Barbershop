import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static String? get authToken => _authToken;

  static String? _authToken;
  static Map<String, dynamic>? currentUser;

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );
      print('REG STATUS: ${response.statusCode} BODY: ${response.body}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Registration Error: $e');
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('LOGIN STATUS: ${response.statusCode} BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'] ?? data['token'];
        currentUser = data['user'];
        return true;
      }
      return false;
    } catch (e) {
      print('Network Exception occurred: $e');
      return false;
    }
  }

  static Future<List<dynamic>> fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'), headers: _getHeaders());
      print('SERVICES STATUS: ${response.statusCode} BODY: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error downloading services table: $e');
      return [];
    }
  }

  static Future<List<dynamic>> fetchBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings'), headers: _getHeaders());
      print('BOOKINGS STATUS: ${response.statusCode} BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded;
        } else {
          print('Unexpected bookings response shape: $decoded');
          return [];
        }
      } else {
        print('Failed to pull bookings registry: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error connecting to bookings database table: $e');
      return [];
    }
  }

  static void logout() {
    _authToken = null;
    currentUser = null;
  }
}