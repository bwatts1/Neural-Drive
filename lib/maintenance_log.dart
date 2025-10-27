import 'package:flutter/material.dart';
import 'database_helper.dart';

class MaintenanceLog extends StatefulWidget {
  const MaintenanceLog({super.key});

  @override
  State<MaintenanceLog> createState() => _MaintenanceLogState();
}

class _MaintenanceLogState extends State<MaintenanceLog> {
  List<Map<String, dynamic>> _reports = [];
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await DbHelper().getReports();
    _updateStateWithReports(reports);
  }

  void _updateStateWithReports(List<Map<String, dynamic>> reports) {
    double total = 0.0;
    for (var r in reports) {
      total += (r['price'] ?? 0).toDouble();
    }
    setState(() {
      _reports = reports;
      _total = total;
    });
  }

  Future<void> _addOrEditReport({Map<String, dynamic>? existing}) async {
    final nameController = TextEditingController(text: existing?['name']);
    final dateController = TextEditingController(text: existing?['date']);
    final priceController = TextEditingController(
        text: existing != null ? existing['price'].toString() : '');

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(existing == null ? "Add Report" : "Edit Report"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: dateController, decoration: const InputDecoration(labelText: "Date")),
              TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final date = dateController.text.trim().isNotEmpty ? dateController.text.trim() : DateTime.now().toIso8601String();
                final price = double.tryParse(priceController.text.trim());

                if (name.isNotEmpty && price != null) {
                  if (existing == null) {
                    await DbHelper().insertReport({'name': name, 'date': date, 'price': price});
                  } else {
                    await DbHelper().updateReport(existing['id'], {'name': name, 'date': date, 'price': price});
                  }
                  Navigator.pop(context);
                  _loadReports();
                }
              },
              child: Text(existing == null ? "Add" : "Update"),
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
      ),
      body: Column(
        children: [
          Expanded(
            child: _reports.isEmpty
                ? const Center(child: Text("No reports yet."))
                : ListView.builder(
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return ListTile(
                        title: Text(report['name']),
                        subtitle: Text('${report['date']} • \$${report['price'].toStringAsFixed(2)}'),
                        onTap: () => _addOrEditReport(existing: report),
                        onLongPress: () async {
                          await DbHelper().deleteReport(report['id']);
                          _loadReports();
                        },
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: Text(
              'Total: \$${_total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditReport(),
        child: const Icon(Icons.add),
      ),
    );
  }
}