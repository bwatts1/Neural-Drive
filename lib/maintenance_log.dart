import 'package:flutter/material.dart';
import 'main.dart';

class MaintenanceLog extends StatelessWidget{
  const MaintenanceLog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(

        ),
      bottomNavigationBar: buildMyNavBar(context),
    );
  }
Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.book, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/maintenanceLog');
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/profileScreen');
            },
          ),
        ],
      ),
    );
  }
}