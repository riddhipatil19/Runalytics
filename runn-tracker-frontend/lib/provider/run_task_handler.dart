import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class RunTaskHandler implements TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // This is called once when the service starts.
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // This is called repeatedly while the service is running.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // This is called when the service is destroyed.
  }

  @override
  void onNotificationPressed() {
    // Optional: Called when user taps the notification.
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Optional: Handle custom notification button taps here.
  }

  @override
  void onNotificationDismissed() {
    // Optional: Called when user dismisses the notification.
  }

  @override
  void onReceiveData(Map<String, dynamic> data) {
    // Optional: For receiving data from main isolate.
    final distance = data['distance'] ?? '0.00 km';
    final pace = data['pace'] ?? '0.00 min/km';

    FlutterForegroundTask.updateService(
      notificationTitle: 'Run in progress',
      notificationText: 'Distance: $distance | Pace: $pace',
    );
  }
}
