import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/fx.dart';
import 'home_screen.dart';
import '../scan/scan_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _go(int i) => setState(() => _selectedIndex = i);

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(onTab: _go),
      ScanScreen(onBack: () => _go(0)),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: _FloatingNav(index: _selectedIndex, onTap: _go),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _FloatingNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 96,
        child: Stack(
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: 10,
              height: 68,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: Fx.card,
                ),
                child: Row(
                  children: [
                    _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        active: index == 0,
                        onTap: () => onTap(0)),
                    _NavItem(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan',
                        active: index == 1,
                        onTap: () => onTap(1)),
                    const Expanded(child: SizedBox()),
                    _NavItem(
                        icon: Icons.history_rounded,
                        label: 'History',
                        active: index == 2,
                        onTap: () => onTap(2)),
                    _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        active: index == 3,
                        onTap: () => onTap(3)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: _ScanFab(onTap: () => onTap(1))),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryDark : AppColors.textLight;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _ScanFab extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5FAE38), Color(0xFF3A8721)],
          ),
          boxShadow: Fx.glow(AppColors.primaryDark, alpha: 0.4, blur: 16, dy: 8),
        ),
        child: const Icon(Icons.qr_code_scanner_rounded,
            color: Colors.white, size: 32),
      ),
    );
  }
}
