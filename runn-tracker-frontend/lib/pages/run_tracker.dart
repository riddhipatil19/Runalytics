import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:runn_track/api/api_run.dart';
import 'package:runn_track/provider/run_provider.dart';
import 'package:runn_track/util/shared_pref_helper.dart';

class RunTracker extends StatefulWidget {
  const RunTracker({super.key});

  @override
  State<RunTracker> createState() => _RunTrackerState();
}

class _RunTrackerState extends State<RunTracker> {
  String _status = "Checking permissions...";
  bool _permissionsGranted = false;
  final MapController _mapController = MapController();

  final ApiRun service = ApiRun();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool locationGranted = await _checkLocationPermission();
    setState(() {
      _permissionsGranted = locationGranted;
      _status = locationGranted
          ? "Tap Start to begin tracking."
          : "Permissions required to track run.";
    });
    if (locationGranted) {
      final provider = Provider.of<RunTrackerProvider>(context, listen: false);
      await provider.initialize();
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  @override
  void dispose() {
    Provider.of<RunTrackerProvider>(context, listen: false).disposeProvider();
    super.dispose();
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit Run?"),
            content:
                const Text("You have an active run. Stop it before exiting?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Exit"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        final isTracking =
            Provider.of<RunTrackerProvider>(context, listen: false).isTracking;
        if (isTracking) {
          final shouldExit = await _showExitConfirmation(context);
          return shouldExit;
        }
        return true;
      },
      child: Scaffold(
        body: _permissionsGranted
            ? Consumer<RunTrackerProvider>(
                builder: (context, provider, _) {
                  final currentLocation = provider.currentLocation;
                  return Column(
                    children: [
                      // 📍 Map
                      Container(
                        height: screenHeight * 0.5,
                        child: currentLocation == null
                            ? const Center(child: Text("Getting location..."))
                            : FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: currentLocation,
                                  initialZoom: 18,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                                    subdomains: ['a', 'b', 'c', 'd'],
                                    userAgentPackageName:
                                        'com.example.runn_track',
                                    retinaMode:
                                        RetinaMode.isHighDensity(context),
                                  ),
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: provider.routePoints,
                                        color: Colors.blue,
                                        strokeWidth: 4,
                                      ),
                                    ],
                                  ),
                                  MarkerLayer(
                                    markers: provider.routePoints.isNotEmpty
                                        ? [
                                            Marker(
                                              width: 80,
                                              height: 80,
                                              point: provider.routePoints.last,
                                              child: const Icon(
                                                  Icons.location_pin,
                                                  size: 40,
                                                  color: Colors.red),
                                            ),
                                          ]
                                        : [],
                                  )
                                ],
                              ),
                      ),

                      // 📊 Stats Container with Polished UI
                      Container(
                        height: screenHeight * 0.5,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        child: (!provider.isTracking &&
                                provider.endTime != null)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "🏁 Run Summary",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  statRow(
                                    icon: Icons.flag,
                                    label: "Start",
                                    value: provider.startTime != null
                                        ? provider.startTime!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[1]
                                            .split('.')[0]
                                        : '--',
                                  ),
                                  statRow(
                                    icon: Icons.stop_circle,
                                    label: "End",
                                    value: provider.endTime!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[1]
                                        .split('.')[0],
                                  ),
                                  statRow(
                                    icon: Icons.timer,
                                    label: "Duration",
                                    value: Duration(seconds: provider.seconds)
                                        .toString()
                                        .split('.')
                                        .first,
                                  ),
                                  statRow(
                                    icon: Icons.directions_walk,
                                    label: "Distance",
                                    value: provider.totalDistance < 1
                                        ? "${(provider.totalDistance * 1000).toStringAsFixed(0)} m"
                                        : "${provider.totalDistance.toStringAsFixed(2)} km",
                                  ),
                                  statRow(
                                    icon: Icons.speed,
                                    label: "Pace",
                                    value:
                                        "${provider.pace.toStringAsFixed(2)} min/km",
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: provider.isSaving
                                              ? null
                                              : () async {
                                                  provider.setSaving(true);
                                                  final token =
                                                      await SharedPrefHelper
                                                          .getToken();
                                                  final result = await service
                                                      .createRun(
                                                          token: token!,
                                                          startTime: provider
                                                              .startTime!
                                                              .toIso8601String(),
                                                          endTime: provider
                                                              .endTime!
                                                              .toIso8601String(),
                                                          totalDistance: provider
                                                              .totalDistance,
                                                          seconds:
                                                              provider.seconds,
                                                          pace: provider.pace);
                                                  provider.setSaving(false);
                                                  if (result['status'] == 200) {
                                                    Fluttertoast.showToast(
                                                        msg: result['message'],
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.green,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                    provider
                                                        .disposeProvider(); // reset UI
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg: result[
                                                                'message'] ??
                                                            'Something went wrong',
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                          ),
                                          child: provider.isSaving
                                              ? const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                )
                                              : const Text(
                                                  "Save Run",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            provider.disposeProvider();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                          ),
                                          child: const Text(
                                            "Discard",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  statRow(
                                    icon: Icons.flag,
                                    label: "Start",
                                    value: provider.startTime != null
                                        ? provider.startTime!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[1]
                                            .split('.')[0]
                                        : '--',
                                  ),
                                  statRow(
                                    icon: Icons.timer,
                                    label: "Duration",
                                    value: Duration(seconds: provider.seconds)
                                        .toString()
                                        .split('.')
                                        .first,
                                  ),
                                  statRow(
                                    icon: Icons.directions_walk,
                                    label: "Distance",
                                    value: provider.totalDistance < 1
                                        ? "${(provider.totalDistance * 1000).toStringAsFixed(0)} m"
                                        : "${provider.totalDistance.toStringAsFixed(2)} km",
                                  ),
                                  statRow(
                                    icon: Icons.speed,
                                    label: "Pace",
                                    value:
                                        "${provider.pace.toStringAsFixed(2)} min/km",
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: provider.isLoading
                                          ? null
                                          : () async {
                                              if (provider.isTracking) {
                                                await provider.stopTracking();
                                              } else {
                                                await provider.startTracking(
                                                    mapController:
                                                        _mapController);
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        backgroundColor: provider.isTracking
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      child: provider.isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              provider.isTracking
                                                  ? "Stop Run"
                                                  : "Start Run",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ],
                  );
                },
              )
            : Center(
                child: Text(
                  _status,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  Widget statRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
