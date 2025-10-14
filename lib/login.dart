import 'package:flutter/material.dart';
import 'signup.dart';
import 'home_screen.dart';

class Login extends StatelessWidget{
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
    body: Stack(

      ),
    );
  }
}