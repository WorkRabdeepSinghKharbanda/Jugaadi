import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../main.dart';
import '../owner/owner_home_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  Future<void> _viewAsOwnRole() async {
    try {
      final profile = await ApiClient(Config.apiBaseUrl).get('/profile/me') as Map<String, dynamic>;
      if (!mounted) return;
      final isOwner = profile['role'] == 'owner';
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => isOwner ? const OwnerHomeScreen() : const WorkerTabs()),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pages = const [AdminUsersScreen(), AdminJobsScreen()];
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(_index == 0 ? 'Admin · Users' : 'Admin · Jobs'),
        actions: [
          IconButton(icon: const Icon(Icons.swap_horiz_rounded), tooltip: 'View as my role', onPressed: _viewAsOwnRole),
        ],
      ),
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
