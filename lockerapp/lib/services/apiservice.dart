import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockerapp/classes/locker.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<Locker>> getLockers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lockers'));

      // Log the status code
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Log the raw response body for debugging
        print('Response Body: ${response.body}');

        List<dynamic> jsonList = jsonDecode(response.body);

        // Verify that the decoded JSON is a list
        if (jsonList is List) {
          return jsonList.map((json) {
            // Log each decoded JSON object
            print('Decoded JSON: $json');
            return Locker.fromJson(json);
          }).toList();
        } else {
          // Log an error message if the response format is unexpected
          print('Error: Unexpected response format');
          throw Exception('Unexpected response format');
        }
      } else {
        // Log the status code and response body for error cases
        print('Error: Status Code ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception(
            'Failed to load lockers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the caught exception
      print('Error occurred: $e');
      throw Exception('Failed to load lockers: $e');
    }
  }

  Future<Locker> addLocker(Locker locker) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lockers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(locker.toJson()),
      );

      // Log the status code
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        // Log the raw response body for debugging
        print('Response Body: ${response.body}');

        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Log the decoded JSON object
        print('Decoded JSON: $jsonResponse');

        return Locker.fromJson(jsonResponse);
      } else {
        // Log the status code and response body for error cases
        print('Error: Status Code ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception(
            'Failed to add locker. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the caught exception
      print('Error occurred: $e');
      throw Exception('Failed to add locker: $e');
    }
  }

  Future<Locker> updateLocker(int id, Locker locker) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/lockers/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(locker.toJson()),
      );

      // Log the status code
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Log the raw response body for debugging
        print('Response Body: ${response.body}');

        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Log the decoded JSON object
        print('Decoded JSON: $jsonResponse');

        return Locker.fromJson(jsonResponse);
      } else {
        // Log the status code and response body for error cases
        print('Error: Status Code ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception(
            'Failed to update locker. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the caught exception
      print('Error occurred: $e');
      throw Exception('Failed to update locker: $e');
    }
  }

  Future<void> deleteLocker(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/lockers/$id'));

      // Log the status code
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Log a successful deletion message
        print('Locker deleted successfully');
      } else {
        // Log the status code and response body for error cases
        print('Error: Status Code ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception(
            'Failed to delete locker. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the caught exception
      print('Error occurred: $e');
      throw Exception('Failed to delete locker: $e');
    }
  }
}
