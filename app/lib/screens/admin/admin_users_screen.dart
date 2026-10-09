import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/admin/users');
    return data as List<dynamic>;
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _toggleVerified(Map<String, dynamic> user) async {
    try {
      await ApiClient(Config.apiBaseUrl).patch('/admin/users/${user['id']}', {'is_verified': !(user['is_verified'] == true)});
      _refresh();
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    }
  }

  Future<void> _delete(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate this user?'),
        content: Text('${user['full_name']} will be soft-deleted and signed out of their account.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient(Config.apiBaseUrl).post('/admin/users/${user['id']}/delete');
      if (mounted) showAppToast(context, 'User deactivated');
      _refresh();
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return RefreshIndicator(
      color: c.accent,
      onRefresh: () async => _refresh(),
      child: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: c.accent));
          }
          if (snapshot.hasError) {
            return Center(child: ErrorStrip('${snapshot.error}'));
          }
          final users = snapshot.data!;
          if (users.isEmpty) return const EmptyState(icon: Icons.people_outline_rounded, text: 'No users');
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
            itemCount: users.length,
            itemBuilder: (context, i) {
              final user = users[i] as Map<String, dynamic>;
              final deleted = user['is_deleted'] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['full_name'] as String? ?? '-', style: AppText.title),
                                const SizedBox(height: 2),
                                Text('${user['role']} · ${user['phone']}', style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                              ],
                            ),
                          ),
                          if (user['is_admin'] == true) const PillBadge(label: 'Admin', tone: PillTone.accent),
                          if (deleted) const PillBadge(label: 'Deleted', tone: PillTone.danger),
                          if (user['is_verified'] == true && !deleted) const PillBadge.verified(),
                        ],
                      ),
                      if (!deleted) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: NeuButton(
                                label: user['is_verified'] == true ? 'Unverify' : 'Verify',
                                variant: NeuButtonVariant.ghost,
                                height: 40,
                                onPressed: () => _toggleVerified(user),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: NeuButton(label: 'Deactivate', variant: NeuButtonVariant.danger, height: 40, onPressed: () => _delete(user)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
