import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:runn_track/main_nav.dart';
import 'package:runn_track/pages/login.dart';
import 'package:runn_track/pages/run_tracker.dart';
import 'package:runn_track/pages/splash.dart';
import 'package:runn_track/provider/run_provider.dart';
import 'package:runn_track/provider/server_ping_task.dart';
import 'package:runn_track/util/shared_pref_helper.dart';

void startCallback() {
  FlutterForegroundTask.setTaskHandler(ServerPingTaskHandler());
}

void _startPingService() async {
  await FlutterForegroundTask.startService(
    notificationTitle: 'Runn Track is active',
    notificationText: 'Keeping server awake ⏱️',
    callback: startCallback,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🔧 Initialize foreground task
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'run_tracking_channel',
      channelName: 'Run Tracking',
      channelDescription: 'Tracks your run in the background.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.drawable,
        resPrefix: ResourcePrefix.ic,
        name: 'notification', // Make sure launcher icon exists
      ),
      isSticky: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 300000, // 5min
    ),
  );
  // Start the ping service even before app UI launches
  _startPingService();
  runApp(
    WithForegroundTask(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RunTrackerProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initLoginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RunTrackerProvider>(context, listen: false);
      provider.startKeepAlivePing();
    });
  }

  void _initLoginStatus() async {
    bool status = await SharedPrefHelper.isLoggedIn();
    setState(() {
      _isLoggedIn = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runn Tracker',
      home: _isLoggedIn! ? MainNavScreen() : Login(),
    );
  }
}
