import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database.dart';
import '../../shared/providers/nav_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top + 64;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 100),
      children: [
        Text('Library', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Swipe through your gallery and clean it fast.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.swipe),
            title: const Text('Start cleaning'),
            subtitle: const Text('Pick folders, then swipe to delete/keep'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ref.read(navTabProvider.notifier).setTab(NavTab.swipe),
          ),
        ),
        const SizedBox(height: 24),
        Text('Analytics', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait([
            DatabaseService.instance.getTodayStats(),
            DatabaseService.instance.getLifetimeStats(),
          ]),
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) return const Center(child: CircularProgressIndicator());
            
            final today = data[0];
            final lifetime = data[1];

            return Column(
              children: [
                _StatsCard(
                  title: 'Today',
                  reviewed: today['reviewed'] ?? 0,
                  deleted: today['deleted'] ?? 0,
                  space: _formatBytes(today['space_freed'] ?? 0),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(height: 12),
                _StatsCard(
                  title: 'Lifetime',
                  reviewed: lifetime['reviewed'] ?? 0,
                  deleted: lifetime['deleted'] ?? 0,
                  space: _formatBytes(lifetime['space_freed'] ?? 0),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final int reviewed;
  final int deleted;
  final String space;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.reviewed,
    required this.deleted,
    required this.space,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Icon(Icons.insights_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Reviewed', value: reviewed.toString()),
                _StatItem(label: 'Deleted', value: deleted.toString()),
                _StatItem(label: 'Space Freed', value: space),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

