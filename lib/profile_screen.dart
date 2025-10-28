import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DbHelper dbHelper = DbHelper();
  String? username;
  int? userId;
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');

    if (savedUsername != null) {
      final db = await dbHelper.database;
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [savedUsername],
      );

      if (result.isNotEmpty) {
        setState(() {
          username = result.first['username'] as String?;
          userId = result.first['id'] as int?;
        });
        _loadVehicles();
      }
    }
  }

  Future<void> _loadVehicles() async {
    if (userId == null) return;
    final db = await dbHelper.database;
    final result = await db.query(
      'vehicles',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    setState(() {
      _vehicles = result;
    });
  }

  Future<void> _addOrEditVehicle({Map<String, dynamic>? vehicle}) async {
    final TextEditingController nameController =
        TextEditingController(text: vehicle?['name'] ?? '');
    final TextEditingController makeController =
        TextEditingController(text: vehicle?['make'] ?? '');
    final TextEditingController modelController =
        TextEditingController(text: vehicle?['model'] ?? '');
    final TextEditingController yearController =
        TextEditingController(text: vehicle?['year'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Make'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = await dbHelper.database;
              final newVehicle = {
                'userId': userId,
                'name': nameController.text,
                'make': makeController.text,
                'model': modelController.text,
                'year': yearController.text,
              };
              if (vehicle == null) {
                await db.insert('vehicles', newVehicle);
              } else {
                await db.update(
                  'vehicles',
                  newVehicle,
                  where: 'id = ?',
                  whereArgs: [vehicle['id']],
                );
              }
              Navigator.pop(context);
              _loadVehicles();
            },
            child: Text(vehicle == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(int id) async {
    final db = await dbHelper.database;
    await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
    _loadVehicles();
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: username == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage('assets/profile_placeholder.png'),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      username ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'User ID: ${userId ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 25),
                    const Divider(thickness: 1.2),

                    // VEHICLES SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Vehicles',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () => _addOrEditVehicle(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _vehicles.isEmpty
                        ? const Text(
                            'No vehicles added yet.',
                            style: TextStyle(color: Colors.grey),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = _vehicles[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.directions_car),
                                  title: Text(vehicle['name']),
                                  subtitle: Text(
                                      '${vehicle['make']} ${vehicle['model']} (${vehicle['year']})'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.orange),
                                        onPressed: () => _addOrEditVehicle(
                                            vehicle: vehicle),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteVehicle(vehicle['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

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
