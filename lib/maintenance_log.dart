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
      total += double.tryParse(r['price'].toString()) ?? 0.0;
    }
    setState(() {
      _reports = reports;
      _total = total;
    });
  }

  Future<void> _addOrEditReport({Map<String, dynamic>? existing}) async {
    final nameController = TextEditingController(text: existing?['name']);
    final dateController = TextEditingController(
        text: existing?['date'] ?? DateTime.now().toIso8601String().split('T').first);
    final reminderController = TextEditingController(
        text: existing?['reminder'] ?? '');
    final priceController = TextEditingController(
        text: existing != null ? existing['price'].toString() : '');

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(existing == null ? "Add Report" : "Edit Report"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Maintenance Date"),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dateController.text = picked.toIso8601String().split('T').first;
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reminderController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Reminder Date"),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(reminderController.text) ??
                          DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      reminderController.text = picked.toIso8601String().split('T').first;
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final date = dateController.text.trim();
                final reminder = reminderController.text.trim();
                final price = double.tryParse(priceController.text.trim());

                if (name.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid name and price.")),
                  );
                  return;
                }

                final report = {
                  'name': name,
                  'date': date,
                  'reminder': reminder,
                  'price': price,
                };

                if (existing == null) {
                  await DbHelper().insertReport(report);
                } else {
                  await DbHelper().updateReport(existing['id'], report);
                }

                if (context.mounted) Navigator.pop(context);
                _loadReports();
              },
              child: Text(existing == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog() async {
    final keywordController = TextEditingController();
    final minPriceController = TextEditingController();
    final maxPriceController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Filter Reports"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: keywordController,
                    decoration: const InputDecoration(labelText: "Keyword")),
                TextField(
                    controller: minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Min Price")),
                TextField(
                    controller: maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Max Price")),
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(labelText: "Start Date (YYYY-MM-DD)"),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      startDateController.text =
                          picked.toIso8601String().split('T').first;
                    }
                  },
                ),
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(labelText: "End Date (YYYY-MM-DD)"),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      endDateController.text =
                          picked.toIso8601String().split('T').first;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final filtered = await DbHelper().filterReports(
                  keyword: keywordController.text.trim(),
                  minPrice: double.tryParse(minPriceController.text.trim()),
                  maxPrice: double.tryParse(maxPriceController.text.trim()),
                  startDate: startDateController.text.trim(),
                  endDate: endDateController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
                _updateStateWithReports(filtered);
              },
              child: const Text("Apply"),
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
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog),
        ],
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
                        subtitle: Text(
                          'Maintenance: ${report['date'] ?? 'N/A'}'
                          '\nReminder: ${report['reminder'] ?? '—'}'
                          '\nPrice: \$${(report['price'] ?? 0).toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        onTap: () => _addOrEditReport(existing: report),
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Report"),
                              content: const Text("Are you sure you want to delete this report?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await DbHelper().deleteReport(report['id']);
                            _loadReports();
                          }
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
