import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'home_screen.dart';
import 'splash.dart';

void main() {
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
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const Login(),
        '/signUp': (context) => const SignUp(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}