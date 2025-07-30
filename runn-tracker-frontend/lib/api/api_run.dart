import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class ApiRun {
  static const String _baseUrl = "http://10.0.2.2:8080";

  Future<Map<String, dynamic>> createRun(
      {required String token,
      required String startTime,
      required String endTime,
      required double totalDistance,
      required int seconds,
      required double pace}) async {
    final body = {
      "startTime": startTime,
      "endTime": endTime,
      "totalDistanceKm": totalDistance,
      "durationSeconds": seconds,
      "averagePace": pace
    };

    final url = Uri.parse("$_baseUrl/create");
    try {
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token'
          },
          body: jsonEncode(body));
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

  Future<List<dynamic>> getMyRuns({required String token}) async {
    final url = Uri.parse("$_baseUrl/my");
    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token'
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>> deleteRunById(
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
