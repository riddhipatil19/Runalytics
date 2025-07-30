import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiUser {
  static const String _baseUrl = "http://10.0.2.2:8080";

  Future<Map<String, dynamic>> deleteUserById(
      {required int id, required String token}) async {
    final url = Uri.parse("$_baseUrl/delete/$id");
    try {
      final response = await http.delete(url, headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token'
      });
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
}
