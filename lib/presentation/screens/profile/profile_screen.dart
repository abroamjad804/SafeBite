import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_profile_model.dart';
import '../../widgets/common/fx.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              PageHeader(
                title: 'Health Profile',
                action: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.ink),
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                  child: Column(
                    children: [
                      // Identity card
                      RaisedCard(
                        radius: 24,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 512, maxHeight: 512);
                                if (picked != null) await auth.updateProfile(user.copyWith(profileImageBase64: base64Encode(await picked.readAsBytes())));
                              },
                              child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.mint, AppColors.primaryDark],
                                ),
                                boxShadow: Fx.glow(AppColors.primaryDark,
                                    alpha: 0.3, blur: 14, dy: 6),
                              ),
                              alignment: Alignment.center,
                              child: user.profileImageBase64 != null
                                  ? ClipOval(child: Image.memory(base64Decode(user.profileImageBase64!), width: 68, height: 68, fit: BoxFit.cover))
                                  : user.name.isNotEmpty
                                  ? Text(user.name[0].toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white))
                                  : const Icon(Icons.person_rounded,
                                      color: Colors.white, size: 34),
                            ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink)),
                                  const SizedBox(height: 2),
                                  Text(user.isGuest ? 'Guest account' : '${user.email}${user.age > 0 ? ' • Age ${user.age}' : ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary)),
                                  const SizedBox(height: 8),
                                  const InfoChip(
                                      label: 'Healthy Explorer',
                                      color: AppColors.primary,
                                      icon: Icons.eco_rounded),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _ProfileCompletenessCard(user: user),
                      const SizedBox(height: 18),

                      _ProfileSection(
                        title: 'Allergies',
                        icon: Icons.shield_outlined,
                        color: AppColors.avoid,
                        description: 'Treated as hard constraints — override PHSS score',
                        items: user.allergies,
                        options: const [
                          'Peanut', 'Tree Nuts', 'Milk', 'Egg', 'Wheat', 'Gluten',
                          'Soy', 'Fish', 'Shellfish', 'Sesame', 'Mustard', 'Celery',
                        ],
                        onUpdate: (items) =>
                            auth.updateProfile(user.copyWith(allergies: items)),
                      ),
                      const SizedBox(height: 14),
                      _ProfileSection(
                        title: 'Avoid List',
                        icon: Icons.block_rounded,
                        color: const Color(0xFFE67E22),
                        description: 'Ingredients you prefer to avoid',
                        items: user.avoidList,
                        options: const [
                          'MSG', 'Artificial Colors', 'Artificial Sweeteners',
                          'High Fructose Corn Syrup', 'Trans Fat', 'BHA', 'BHT',
                          'Sodium Nitrate', 'Carrageenan', 'Aspartame',
                        ],
                        onUpdate: (items) =>
                            auth.updateProfile(user.copyWith(avoidList: items)),
                      ),
                      const SizedBox(height: 14),
                      _ProfileSection(
                        title: 'Health Conditions',
                        icon: Icons.favorite_border_rounded,
                        color: AppColors.primary,
                        description: 'Dietary needs — affects H factor (40% of PHSS)',
                        items: user.dietaryNeeds,
                        options: const [
                          'Low Sodium', 'Low Saturated Fat', 'Low Cholesterol',
                          'Diabetic Friendly', 'Low Potassium', 'Renal Diet',
                        ],
                        onUpdate: (items) =>
                            auth.updateProfile(user.copyWith(dietaryNeeds: items)),
                      ),
                      const SizedBox(height: 14),
                      _ProfileSection(
                        title: 'Goals',
                        icon: Icons.track_changes_rounded,
                        color: AppColors.primary,
                        description: 'Nutrition goals — affects N factor (30% of PHSS)',
                        items: user.nutritionGoals,
                        options: const [
                          'Reduce Sugar', 'Reduce Calories', 'Increase Protein',
                          'Reduce Carbs', 'Increase Fiber', 'Monitor Fat',
                        ],
                        onUpdate: (items) =>
                            auth.updateProfile(user.copyWith(nutritionGoals: items)),
                      ),
                      const SizedBox(height: 14),
                      _ProfileSection(
                        title: 'Dietary Preferences',
                        icon: Icons.spa_outlined,
                        color: AppColors.primary,
                        description: 'Affects D factor (20% of PHSS)',
                        items: user.dietaryPreferences,
                        options: const [
                          'Vegetarian', 'Vegan', 'Halal', 'Kosher',
                          'Gluten-Free', 'Dairy-Free',
                        ],
                        onUpdate: (items) => auth
                            .updateProfile(user.copyWith(dietaryPreferences: items)),
                      ),
                      const SizedBox(height: 20),

                      const _PhssCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhssCard extends StatelessWidget {
  const _PhssCard();

  Widget _bar(String label, String letter, double w, Color c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
            child: Text(letter,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: w,
                minHeight: 7,
                backgroundColor: c.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(c),
              ),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text('${(w * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RaisedCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              IconBadge(icon: Icons.calculate_outlined, size: 42),
              SizedBox(width: 12),
              Expanded(
                child: Text('How PHSS is Calculated',
                    style: TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _bar('Health-related needs', 'H', 0.40, AppColors.primaryDark),
          _bar('Nutrition goals', 'N', 0.30, AppColors.primary),
          _bar('Dietary preferences', 'D', 0.20, AppColors.secondary),
          _bar('General ingredients', 'G', 0.10, AppColors.caution),
          const SizedBox(height: 4),
          const Text(
            '80–100 = Safe*   |   50–79 = Caution   |   0–49 = Avoid',
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProfileCompletenessCard extends StatelessWidget {
  final UserProfile user;
  const _ProfileCompletenessCard({required this.user});

  int get _filledCount {
    int count = 0;
    if (user.allergies.isNotEmpty) count++;
    if (user.avoidList.isNotEmpty) count++;
    if (user.dietaryNeeds.isNotEmpty) count++;
    if (user.nutritionGoals.isNotEmpty) count++;
    if (user.dietaryPreferences.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final filled = _filledCount;
    final percent = filled / 5;

    return RaisedCard(
      radius: 24,
      child: Row(
        children: [
          ScoreRing(
            value: percent * 100,
            color: AppColors.primary,
            size: 68,
            stroke: 7,
            child: Text('${(percent * 100).round()}%',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.ink)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profile Completeness',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    Text('$filled / 5',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  percent == 1.0
                      ? 'Profile complete — scoring is fully personalized'
                      : 'Complete your profile for more accurate scores',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> items;
  final List<String> options;
  final Function(List<String>) onUpdate;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.items,
    required this.options,
    required this.onUpdate,
  });

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final customController = TextEditingController();
        final updatedItems = List<String>.from(items);
        return StatefulBuilder(builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    IconBadge(icon: icon, color: color, size: 40),
                    const SizedBox(width: 12),
                    Text('Add $title',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Type one or more entries separated by commas.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. peanut allergy, lactose intolerance...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (customController.text.trim().isNotEmpty) {
                            final additions = customController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty && !updatedItems.any((old) => old.toLowerCase() == e.toLowerCase())).toList();
                            if (additions.isNotEmpty) {
                              updatedItems.addAll(additions);
                              onUpdate(List<String>.from(updatedItems));
                            }
                            customController.clear();
                            setModalState(() {});
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RaisedCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: color, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    Text(description,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showAddDialog(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: AppColors.primaryDark, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items
                  .map(
                    (item) => Chip(
                      label: Text(item,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: color)),
                      backgroundColor: color.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      deleteIcon: const Icon(Icons.close_rounded, size: 15),
                      deleteIconColor: color,
                      onDeleted: () {
                        final updated = List<String>.from(items)..remove(item);
                        onUpdate(updated);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  )
                  .toList(),
            )
          else
            const Text('None',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight)),
        ],
      ),
    );
  }
}
