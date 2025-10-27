import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';

class MaintenanceLog extends StatelessWidget {
  const MaintenanceLog({super.key});

  Future<void> _addReport(BuildContext context) async {
    final nameController = TextEditingController();
    final dateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add New Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Maintenance Report"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final date = dateController.text.trim().isNotEmpty
                    ? dateController.text.trim()
                    : DateTime.now().toIso8601String();

                await DbHelper().insertReport({
                  'name': name,
                  'date': date,
                });

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Log'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text("No reports yet."),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addReport(context),
        child: const Icon(Icons.add),
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