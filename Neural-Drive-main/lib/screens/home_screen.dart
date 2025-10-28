import 'package:flutter/material.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  static const List<Widget> _tabs = [
    _HomeTab(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _tabs[_tabIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _tabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Neural Drive'),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildWelcomeCard(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: _buildSectionTitle('Upcoming Maintenance'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildUpcomingMaintenance(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: _buildSectionTitle('Recent Activity'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildRecentActivity(),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your vehicles with ease',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUpcomingMaintenance() {
    final reminders = const [
      {
        'title': 'Oil Change - Toyota Camry',
        'date': '2025-11-15',
        'severity': 2,
      },
      {
        'title': 'Tire Rotation - Honda Civic',
        'date': '2025-11-20',
        'severity': 1,
      },
      {
        'title': 'Brake Inspection - BMW 3 Series',
        'date': '2025-12-01',
        'severity': 2,
      },
    ];

    return Column(
      children: reminders
          .map((reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _ReminderTile(
                  title: reminder['title'] as String,
                  date: reminder['date'] as String,
                  severity: reminder['severity'] as int,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRecentActivity() {
    final activities = const [
      {
        'title': 'Oil Change',
        'subtitle': 'Toyota Camry • $45.99',
        'icon': Icons.local_gas_station,
      },
      {
        'title': 'Tire Replacement',
        'subtitle': 'Honda Civic • $420.00',
        'icon': Icons.car_repair,
      },
      {
        'title': 'Brake Service',
        'subtitle': 'BMW 3 Series • $325.50',
        'icon': Icons.settings,
      },
    ];

    return Column(
      children: activities
          .map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _ActivityTile(
                  title: activity['title'] as String,
                  subtitle: activity['subtitle'] as String,
                  icon: activity['icon'] as IconData,
                ),
              ))
          .toList(),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final String title;
  final String date;
  final int severity; // 0 = low, 1 = medium, 2 = high

  const _ReminderTile({
    required this.title,
    required this.date,
    required this.severity,
  });

  Color get _severityColor {
    switch (severity) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.notifications_active,
            color: _severityColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Due: $date'),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _severityColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

