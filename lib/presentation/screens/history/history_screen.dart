import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/scan_provider.dart';
import '../../../data/models/scan_history_model.dart';
import '../../widgets/common/fx.dart';

enum _Filter { all, scans, reports }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _Filter _filter = _Filter.all;

  void _confirmClear(BuildContext context, ScanProvider scan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear History'),
        content: const Text('This will delete all scan records. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.avoid),
            onPressed: () {
              scan.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final history = scan.history;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              PageHeader(
                title: 'History',
                action: history.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.ink),
                        onPressed: () => _confirmClear(context, scan),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    _FilterPill(
                        label: 'All',
                        selected: _filter == _Filter.all,
                        onTap: () => setState(() => _filter = _Filter.all)),
                    const SizedBox(width: 10),
                    _FilterPill(
                        label: 'Scans',
                        selected: _filter == _Filter.scans,
                        onTap: () => setState(() => _filter = _Filter.scans)),
                    const SizedBox(width: 10),
                    _FilterPill(
                        label: 'Reports',
                        selected: _filter == _Filter.reports,
                        onTap: () => setState(() => _filter = _Filter.reports)),
                  ],
                ),
              ),
              Expanded(
                child: _filter == _Filter.reports
                    ? _ReportsView(history: history)
                    : history.isEmpty
                        ? const _EmptyHistory()
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                            children: [
                              if (_filter == _Filter.all)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: RaisedCard(
                                    radius: 20,
                                    padding: const EdgeInsets.all(14),
                                    onTap: () =>
                                        setState(() => _filter = _Filter.reports),
                                    child: const Row(
                                      children: [
                                        IconBadge(
                                            icon: Icons.bar_chart_rounded,
                                            size: 46),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Monthly health report',
                                                  style: TextStyle(
                                                      fontSize: 14.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.ink)),
                                              Text('See your trends',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color:
                                                          AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right_rounded,
                                            color: AppColors.textLight),
                                      ],
                                    ),
                                  ),
                                ),
                              ...history.map((item) => _HistoryCard(
                                    item: item,
                                    onDelete: () => scan.removeHistoryItem(item.id),
                                  )),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected
              ? Fx.glow(AppColors.primaryDark, alpha: 0.3, blur: 12, dy: 5)
              : null,
          border: selected ? null : Border.all(color: AppColors.divider),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

String _when(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  final time = DateFormat('h:mm a').format(d);
  if (diff == 0) return 'Today, $time';
  if (diff == 1) return 'Yesterday, $time';
  return DateFormat('MMM d, yyyy').format(d);
}

class _HistoryCard extends StatelessWidget {
  final ScanHistoryItem item;
  final VoidCallback onDelete;
  const _HistoryCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(item.suitabilityLabel);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RaisedCard(
        radius: 20,
        padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
        child: Row(
          children: [
            ProductThumb(
                name: item.product.name,
                size: 54,
                imageUrl: item.product.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: style.text,
                            style: TextStyle(
                                color: style.color, fontWeight: FontWeight.w800)),
                        TextSpan(
                            text: '  •  ${item.phssScore.toStringAsFixed(0)}/100',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(_when(item.scannedAt),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight)),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 20, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 90),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconBadge(icon: Icons.history_rounded, size: 96),
            SizedBox(height: 22),
            Text('No scans yet',
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
            SizedBox(height: 6),
            Text('Capture an ingredient label to get started',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Reports ─────────────────────────────

class _ReportsView extends StatelessWidget {
  final List<ScanHistoryItem> history;
  const _ReportsView({required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthScans = history
        .where((h) => now.difference(h.scannedAt).inDays < 30)
        .toList();
    final verified =
        monthScans.where((h) => h.suitabilityLabel != 'unverified').toList();
    final avg = verified.isEmpty
        ? null
        : verified.map((h) => h.phssScore).reduce((a, b) => a + b) /
            verified.length;
    int count(String l) =>
        monthScans.where((h) => h.suitabilityLabel == l).length;

    // Weekly averages: index 0 = oldest of the last four weeks.
    final spots = <FlSpot>[];
    for (int w = 0; w < 4; w++) {
      final newestDays = (3 - w) * 7;
      final inWeek = verified.where((h) {
        final d = now.difference(h.scannedAt).inDays;
        return d >= newestDays && d < newestDays + 7;
      }).toList();
      if (inWeek.isNotEmpty) {
        final a = inWeek.map((h) => h.phssScore).reduce((x, y) => x + y) /
            inWeek.length;
        spots.add(FlSpot(w.toDouble(), a));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
      children: [
        RaisedCard(
          radius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const IconBadge(icon: Icons.bar_chart_rounded, size: 72),
              const SizedBox(height: 12),
              const Text('Your Health Report',
                  style: TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const Text('Monthly Summary',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(label: 'Scans', value: '${monthScans.length}', color: AppColors.ink),
                  _Stat(label: 'Avg score', value: avg == null ? '--' : avg.round().toString(), color: AppColors.primaryDark),
                  _Stat(label: 'Safe', value: '${count('safe')}', color: AppColors.safe),
                  _Stat(label: 'Avoid', value: '${count('avoid')}', color: AppColors.avoid),
                ],
              ),
              const SizedBox(height: 18),
              GradientButton(
                label: 'Download PDF',
                icon: Icons.file_download_outlined,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export is coming soon')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RaisedCard(
          radius: 24,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Health Trends',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 14),
              SizedBox(
                height: 170,
                child: spots.isEmpty
                    ? const Center(
                        child: Text('Scan a few products to see your weekly trend.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                      )
                    : LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: 3,
                          minY: 0,
                          maxY: 100,
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: (value, meta) => Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('W${value.toInt() + 1}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary)),
                                ),
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
