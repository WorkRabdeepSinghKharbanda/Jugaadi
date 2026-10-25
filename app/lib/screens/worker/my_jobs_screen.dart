import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/i18n/strings.dart';
import '../../core/paginated_list.dart';
import '../../core/skeleton.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../job_detail_screen.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late Future<void> _future;
  late final _pager = PaginatedList<dynamic>(fetchPage: _fetchPage);
  final _scrollController = ScrollController();
  // On by default — every application the worker's ever made. Picking a date range (via the
  // filter button) turns this off and scopes the list server-side instead of hiding rows from
  // an already-loaded page, which would silently break once there's more than one page of them.
  bool _lifetimeOn = true;
  DateTimeRange? _filterRange;

  @override
  void initState() {
    super.initState();
    _pager.attachScrollController(_scrollController, () => setState(() {}));
    _future = _reload();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchPage(int offset, int limit) async {
    final data = await ApiClient(Config.apiBaseUrl).get('/applications/mine', {
      'limit': limit,
      'offset': offset,
      if (!_lifetimeOn && _filterRange != null)
        'from': _filterRange!.start.toIso8601String().split('T').first,
      if (!_lifetimeOn && _filterRange != null)
        'to': _filterRange!.end.toIso8601String().split('T').first,
    });
    return data as List<dynamic>;
  }

  Future<void> _reload() => _pager.loadFirstPage();

  void _refresh() => setState(() {
    _future = _reload();
  });

  Future<void> _pickFilterRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now.add(const Duration(days: 90)),
      initialDateRange: _filterRange,
    );
    if (range == null) return;
    setState(() {
      _filterRange = range;
      _lifetimeOn = false;
      _future = _reload();
    });
  }

  void _clearFilter() => setState(() {
    _filterRange = null;
    _lifetimeOn = true;
    _future = _reload();
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      title: context.tr('my_applications_title'),
      fullBleed: true,
      actions: [
        NeuIconButton(
          icon: _lifetimeOn
              ? Icons.filter_alt_outlined
              : Icons.filter_alt_rounded,
          semanticLabel: context.tr('filter_by_date'),
          onPressed: _pickFilterRange,
        ),
      ],
      body: RefreshIndicator(
        color: c.accent,
        onRefresh: () async => _refresh(),
        child: FutureBuilder<void>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SkeletonList();
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: AppSpacing.screen,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ErrorStrip(errorMessage(context, snapshot.error!)),
                      const SizedBox(height: AppSpacing.md),
                      NeuButton(
                        label: context.tr('retry'),
                        expand: false,
                        onPressed: _refresh,
                      ),
                    ],
                  ),
                ),
              );
            }
            final applications = _pager.items;
            final hasFilter = !_lifetimeOn && _filterRange != null;
            return Column(
              children: [
                if (hasFilter)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.sm,
                      AppSpacing.gutter,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(
                          '${_filterRange!.start.toIso8601String().split('T').first} → ${_filterRange!.end.toIso8601String().split('T').first}',
                        ),
                        onDeleted: _clearFilter,
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      ),
                    ),
                  ),
                Expanded(
                  child: applications.isEmpty
                      ? Center(
                          child: EmptyState(
                            icon: Icons.inbox_outlined,
                            text: hasFilter
                                ? context.tr('no_applications_in_range')
                                : context.tr('no_applications_yet'),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.gutter,
                            AppSpacing.md,
                            AppSpacing.gutter,
                            GlassNavBar.height + AppSpacing.md,
                          ),
                          itemCount:
                              applications.length + (_pager.hasMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == applications.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: c.accent,
                                  ),
                                ),
                              );
                            }
                            final entry =
                                applications[i] as Map<String, dynamic>;
                            final job = entry['job'] as Map<String, dynamic>;
                            return FadeSlideIn(
                              index: i,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: NeuCard(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => JobDetailScreen(
                                        job: job,
                                        isOwner: false,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              job['title'] as String,
                                              style: AppText.title,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${context.tr('job_status_prefix')} ${job['status']}',
                                              style: AppText.bodySmall.copyWith(
                                                color: c.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PillBadge.status(
                                        entry['status'] as String,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
