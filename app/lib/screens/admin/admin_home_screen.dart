import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import 'admin_jobs_screen.dart';
import 'admin_users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pages = const [AdminUsersScreen(), AdminJobsScreen()];
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: Text(_index == 0 ? 'Admin · Users' : 'Admin · Jobs')),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.work_outline_rounded), label: 'Jobs'),
        ],
      ),
    );
  }
}
