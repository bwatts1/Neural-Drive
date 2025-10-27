import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'login.dart';
import 'signup.dart';
import 'home_screen.dart';
import 'splash.dart';
import 'maintenance_log.dart';
import 'profile_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const AndroidNotificationChannel maintenanceChannel = AndroidNotificationChannel(
    'maintenance_channel', 
    'Maintenance Reminders',
    description: 'Notifications for scheduled maintenance tasks',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(maintenanceChannel);

  final status = await Permission.notification.request();
  if (status.isDenied) {
    debugPrint('Notification permission denied by user.');
  } else if (status.isPermanentlyDenied) {
    debugPrint('Notification permission permanently denied.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halloween Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const Login(),
        '/signUp': (context) => const SignUp(),
        '/home': (context) => const HomeScreen(),
        '/maintenanceLog': (context) => const MaintenanceLog(),
        '/profileScreen': (context) => const ProfileScreen(), // ✅ fixed route
      },
    );
  }
}
