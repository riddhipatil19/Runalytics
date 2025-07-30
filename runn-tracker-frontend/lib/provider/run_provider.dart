import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:runn_track/provider/run_task_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class RunTrackerProvider with ChangeNotifier {
  Timer? _keepAliveTimer;

  void startKeepAlivePing() {
    // Avoid multiple timers
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(Duration(minutes: 12), (_) async {
      try {
        final res =
            await http.get(Uri.parse('https://runn-tracker.onrender.com/'));
        if (res.statusCode == 200) {
          print("✅ Server pinged successfully");
        } else {
          print("⚠️ Server ping failed: ${res.statusCode}");
        }
      } catch (e) {
        print("❌ Error pinging server: $e");
      }
    });
  }

  void stopKeepAlivePing() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  @override
  void dispose() {
    stopKeepAlivePing();
    super.dispose();
  }

  bool isTracking = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<LatLng> routePoints = [];
  LatLng? currentLocation;
  LatLng? startPoint;
  double totalDistance = 0;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  StreamSubscription<Position>? positionStream;

  DateTime? startTime;
  DateTime? endTime;
  int seconds = 0;
  double pace = 0;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  void setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  SendPort? _sendPort;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      currentLocation = LatLng(pos.latitude, pos.longitude);
      notifyListeners();
    } catch (e) {
      debugPrint("Initialization failed: $e");
    }
  }

  Future<void> startTracking({MapController? mapController}) async {
    if (isTracking || _isLoading) return;
    _setLoading(true);

    try {
      await _startForegroundService();

      final pos = await Geolocator.getCurrentPosition();
      startPoint = LatLng(pos.latitude, pos.longitude);
      routePoints = [startPoint!];
      currentLocation = startPoint;
      startTime = DateTime.now();
      totalDistance = 0;
      seconds = 0;
      pace = 0;

      stopwatch.reset();
      stopwatch.start();

      positionStream?.cancel();
      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen((Position newPos) {
        final newLatLng = LatLng(newPos.latitude, newPos.longitude);
        if (routePoints.isEmpty) {
          routePoints.add(newLatLng);
          currentLocation = newLatLng;
          notifyListeners();
          return;
        }

        final last = routePoints.last;
        final distanceInKm = Distance().as(
          LengthUnit.Kilometer,
          last,
          newLatLng,
        );

        if (distanceInKm > 0.003) {
          totalDistance += distanceInKm;
          routePoints.add(newLatLng);
          currentLocation = newLatLng;

          mapController?.move(newLatLng, mapController.camera.zoom);
          notifyListeners();
        }
      });

      int updateCounter = 0;
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        seconds = stopwatch.elapsed.inSeconds;
        pace = totalDistance > 0 ? seconds / 60 / totalDistance : 0;
        updateCounter++;

        if (updateCounter % 60 == 0 && _sendPort != null) {
          _sendPort!.send({
            'distance': totalDistance.toStringAsFixed(2) + ' km',
            'pace': pace.toStringAsFixed(2) + ' min/km',
          });
        }

        notifyListeners();
      });

      isTracking = true;
    } catch (e) {
      debugPrint("Error starting tracking: $e");
    }

    _setLoading(false);
  }

  Future<void> stopTracking() async {
    if (!isTracking || _isLoading) return;
    _setLoading(true);

    try {
      stopwatch.stop();
      timer?.cancel();
      await positionStream?.cancel();
      await _stopForegroundService();
      endTime = DateTime.now();
      isTracking = false;
    } catch (e) {
      debugPrint("Error stopping tracking: $e");
    }

    _setLoading(false);
    notifyListeners();
  }

  void disposeProvider() {
    stopwatch.stop();
    timer?.cancel();
    positionStream?.cancel();
    isTracking = false;
    _isLoading = false;
    // Reset all run data
    routePoints.clear();
    // currentLocation = null;
    startPoint = null;
    totalDistance = 0;
    seconds = 0;
    pace = 0;
    startTime = null;
    endTime = null;
    notifyListeners();
  }

  Future<void> _startForegroundService() async {
    if (!await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Run in progress...',
        notificationText: 'Tracking your run.',
        callback: startCallback,
      );
    }

    // Grab the SendPort after service starts
    _sendPort = IsolateNameServer.lookupPortByName(
        'flutter_foreground_task/isolateComPort');
  }

  Future<void> _stopForegroundService() async {
    await FlutterForegroundTask.stopService();
  }
}

// Top-level callback (must be global function)
void startCallback() {
  FlutterForegroundTask.setTaskHandler(RunTaskHandler());
}
