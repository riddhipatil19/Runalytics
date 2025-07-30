import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiAuth {
  static const String _baseUrl = "http://10.0.2.2:8080";

  Future<Map<String, dynamic>> signUp(
      {required String name,
      required String email,
      required String password}) async {
    final url = Uri.parse("$_baseUrl/signup");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'status': response.statusCode, 'message': data['message']};
      } else {
        return {'status': response.statusCode, 'message': data['message']};
      }
    } catch (e) {
      debugPrint(e.toString());
      return {'status': 500, 'message': 'Something went wrong'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return data;
      }
    } catch (e) {
      debugPrint(e.toString());
      return {
        'status': 'error',
        'message': 'Something went wrong',
      };
    }
  }
}
