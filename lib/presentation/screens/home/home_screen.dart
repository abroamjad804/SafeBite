import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/scan_history_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/scan_provider.dart';
import '../../widgets/common/fx.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onTab;
  const HomeScreen({super.key, this.onTab});

  void _go(int i) => onTab?.call(i);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scan = context.watch<ScanProvider>();
    final user = auth.user;
    final rawName = (user?.name ?? '').trim();
    final first = rawName.isEmpty ? 'there' : rawName.split(' ').first;
    final name = first[0].toUpperCase() + first.substring(1);

    // Health score = average PHSS of verified scans.
    final scored =
        scan.history.where((h) => h.suitabilityLabel != 'unverified').toList();
    final hasScore = scored.isNotEmpty;
    final avg = hasScore
        ? scored.map((h) => h.phssScore).reduce((a, b) => a + b) / scored.length
        : 0.0;
    final String headline;
    final String subline;
    if (!hasScore) {
      headline = "Let's begin!";
      subline = 'Scan a product to get your score.';
    } else if (avg >= 80) {
      headline = 'Excellent!';
      subline = 'Keep it up!';
    } else if (avg >= 50) {
      headline = 'Doing okay';
      subline = 'Small swaps add up.';
    } else {
      headline = 'Needs attention';
      subline = 'Check your Avoid list.';
    }

    final avoidCount =
        scan.history.where((h) => h.suitabilityLabel == 'avoid').length;
    final profileSections = user == null
        ? 0
        : [
            user.allergies,
            user.avoidList,
            user.dietaryNeeds,
            user.nutritionGoals,
            user.dietaryPreferences,
          ].where((l) => l.isNotEmpty).length;

    final insights = <_Insight>[];
    if (profileSections < 3) {
      insights.add(_Insight(
          'Complete your health profile to get personalized scores.',
          () => _go(3)));
    }
    if (avoidCount > 0) {
      insights.add(_Insight(
          '$avoidCount scanned ${avoidCount == 1 ? 'product was' : 'products were'} marked Avoid. Review your history.',
          () => _go(2)));
    }
    if (insights.isEmpty) {
      insights.add(_Insight('Try to reduce high-sodium foods.', null));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, $name 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink)),
                          const SizedBox(height: 2),
                          const Text("Let's make healthier choices today!",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: Fx.card,
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Health score card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF66B53F), Color(0xFF3F8F25)],
                    ),
                    boxShadow:
                        Fx.glow(AppColors.primaryDark, alpha: 0.35, blur: 24, dy: 12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10,
                          top: -4,
                          child: Leaf(
                              size: 90,
                              angle: 2.3,
                              color: Colors.white.withValues(alpha: 0.16)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Health Score',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  ScoreRing(
                                    value: avg,
                                    color: Colors.white,
                                    trackColor: Colors.white.withValues(alpha: 0.25),
                                    size: 112,
                                    stroke: 9,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(hasScore ? avg.round().toString() : '--',
                                            style: const TextStyle(
                                                fontSize: 38,
                                                height: 1,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white)),
                                        Text('/100',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white
                                                    .withValues(alpha: 0.85))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(headline,
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white)),
                                        const SizedBox(height: 4),
                                        Text(subline,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white
                                                    .withValues(alpha: 0.9))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Quick actions
                Row(
                  children: [
                    _QuickAction(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan\nProduct',
                        onTap: () => _go(1)),
                    const SizedBox(width: 12),
                    _QuickAction(
                        icon: Icons.history_rounded,
                        label: 'Your\nHistory',
                        onTap: () => _go(2)),
                    const SizedBox(width: 12),
                    _QuickAction(
                        icon: Icons.person_outline_rounded,
                        label: 'Health\nProfile',
                        onTap: () => _go(3)),
                  ],
                ),
                const SizedBox(height: 26),

                SectionTitle('Quick Insights',
                    trailing: LinkText('View All', onTap: () => _go(2))),
                const SizedBox(height: 12),
                ...insights.take(2).map((i) => _InsightCard(insight: i)),

                if (scan.history.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionTitle('Recent Scans',
                      trailing: LinkText('See all', onTap: () => _go(2))),
                  const SizedBox(height: 12),
                  ...scan.history.take(3).map((item) => _RecentScanTile(item: item)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Insight {
  final String text;
  final VoidCallback? onTap;
  _Insight(this.text, this.onTap);
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: insight.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: AppColors.caution, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(insight.text,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          height: 1.35)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RaisedCard(
        onTap: onTap,
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primaryDark),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  final ScanHistoryItem item;
  const _RecentScanTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RaisedCard(
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ProductThumb(
                name: item.product.name,
                size: 48,
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
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: AppColors.ink)),
                  Text(item.product.brand ?? item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            StatusPill(item.suitabilityLabel),
          ],
        ),
      ),
    );
  }
}
