import 'dart:io';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;

class ServerPingTaskHandler extends TaskHandler {
  DateTime? _lastPing;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _lastPing = DateTime.now().subtract(const Duration(minutes: 6));
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    final now = DateTime.now();
    if (_lastPing == null || now.difference(_lastPing!).inMinutes >= 12) {
      try {
        final response =
            await http.get(Uri.parse('https://runn-tracker.onrender.com/'));
        if (response.statusCode == 200) {
          print("🔁 Ping successful");
        } else {
          print("⚠️ Ping failed: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ Ping error: $e");
      }
      _lastPing = now;
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('🛑 Foreground task stopped');
  }

  @override
  void onButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onRepeatEvent
  }
}
