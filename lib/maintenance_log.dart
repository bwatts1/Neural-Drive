import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main.dart';

class MaintenanceLog extends StatefulWidget {
  const MaintenanceLog({super.key});

  @override
  State<MaintenanceLog> createState() => _MaintenanceLogState();
}

class _MaintenanceLogState extends State<MaintenanceLog> {
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final db = await DbHelper().database;
    final reports = await db.query('reports', orderBy: 'id DESC');
    setState(() {
      _reports = reports;
    });
  }

  Future<void> _addReport(BuildContext context) async {
    final nameController = TextEditingController();
    final dateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add New Report"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Maintenance Report"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date (optional)"),
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

                if (name.isNotEmpty) {
                  await DbHelper().insertReport({'name': name, 'date': date});
                  Navigator.pop(context);
                  _loadReports();
                }
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
      body: _reports.isEmpty
          ? const Center(child: Text("No reports yet."))
          : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return ListTile(
                  title: Text(report['name']),
                  subtitle: Text(report['date']),
                );
              },
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