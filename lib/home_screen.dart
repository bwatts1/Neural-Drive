import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DbHelper dbHelper = DbHelper();

  int? selectedVehicleId;
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> vehicleReports = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  /// Load all vehicles from database
  Future<void> _loadVehicles() async {
    final db = await dbHelper.database;
    final result = await db.query('vehicles');

    setState(() {
      vehicles = result;
      if (vehicles.isNotEmpty) {
        selectedVehicleId = vehicles.first['id'] as int;
        _loadReportsForVehicle(selectedVehicleId!);
      }
    });
  }

  /// Load all reports associated with a specific vehicle_id
  Future<void> _loadReportsForVehicle(int vehicleId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'reports',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );

    setState(() {
      vehicleReports = result;
    });
  }

  /// Format date safely
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  /// --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neural Drive - Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Vehicle:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // VEHICLE DROPDOWN
            if (vehicles.isEmpty)
              const Text("No vehicles found. Add one to get started.")
            else
              DropdownButton<int>(
                value: selectedVehicleId,
                isExpanded: true,
                items: vehicles.map((vehicle) {
                  return DropdownMenuItem<int>(
                    value: vehicle['id'] as int,
                    child: Text(vehicle['name'] ?? 'Unnamed Vehicle'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedVehicleId = value);
                  if (value != null) _loadReportsForVehicle(value);
                },
              ),

            const SizedBox(height: 20),

            const Text(
              "Maintenance Reports:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // REPORT LIST
            Expanded(
              child: vehicleReports.isEmpty
                  ? const Center(
                      child: Text(
                        "No maintenance reports found for this vehicle.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: vehicleReports.length,
                      itemBuilder: (context, index) {
                        final report = vehicleReports[index];
                        final formattedDate = _formatDate(report['date']);
                        final reminder = report['reminder'] ?? 'Maintenance Task';
                        final price = report['price'] != null ? "\$${report['price']}" : '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.build_circle, color: Colors.blue),
                            title: Text(
                              reminder,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Date: $formattedDate"),
                            trailing: Text(
                              price,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  /// Bottom navigation bar
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
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
