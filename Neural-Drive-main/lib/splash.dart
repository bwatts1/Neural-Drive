import 'package:flutter/material.dart';
import 'login.dart';

class Splash extends StatelessWidget{
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splash'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          const Center(
            child: Text("You're not supposed to be here! Redirecting to Login..."),
          ),
          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 2)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed('/login');
                });
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}