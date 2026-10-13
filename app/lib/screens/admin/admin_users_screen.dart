import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/i18n/strings.dart';
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

  void _refresh() => setState(() { _future = _load(); });

  Future<void> _toggleVerified(Map<String, dynamic> user) async {
    try {
      await ApiClient(Config.apiBaseUrl).patch('/admin/users/${user['id']}', {'is_verified': !(user['is_verified'] == true)});
      _refresh();
    } catch (e) {
      if (mounted) showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
    }
  }

  Future<void> _delete(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('deactivate_user_title')),
        content: Text('${user['full_name']} ${ctx.tr('deactivate_user_body')}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(ctx.tr('cancel'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(ctx.tr('deactivate'))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient(Config.apiBaseUrl).post('/admin/users/${user['id']}/delete');
      if (mounted) showAppToast(context, context.tr('user_deactivated'));
      _refresh();
    } catch (e) {
      if (mounted) showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
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
            return Center(child: ErrorStrip(errorMessage(context, snapshot.error!)));
          }
          final users = snapshot.data!;
          if (users.isEmpty) return EmptyState(icon: Icons.people_outline_rounded, text: context.tr('no_users'));
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
                          if (user['is_admin'] == true) PillBadge(label: context.tr('admin_label'), tone: PillTone.accent),
                          if (deleted) PillBadge(label: context.tr('deleted_label'), tone: PillTone.danger),
                          if (user['is_verified'] == true && !deleted) const PillBadge.verified(),
                        ],
                      ),
                      if (!deleted) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: NeuButton(
                                label: user['is_verified'] == true ? context.tr('unverify') : context.tr('verify'),
                                variant: NeuButtonVariant.ghost,
                                height: 40,
                                onPressed: () => _toggleVerified(user),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: NeuButton(label: context.tr('deactivate'), variant: NeuButtonVariant.danger, height: 40, onPressed: () => _delete(user)),
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
