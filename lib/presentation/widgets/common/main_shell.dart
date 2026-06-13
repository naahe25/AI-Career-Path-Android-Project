import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

/// The main app shell: hosts the 5 primary tabs behind a floating, 3D
/// bottom navigation bar.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.work_outline_rounded, Icons.work_rounded, 'Jobs'),
    _NavItem(Icons.route_outlined, Icons.route_rounded, 'Career'),
    _NavItem(Icons.people_alt_outlined, Icons.people_alt_rounded, 'Network'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        items: _items,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _FloatingNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12 + MediaQuery.of(context).padding.bottom * 0.4,
      ),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F242C4D),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final item = items[i];
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: selected ? 16 : 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: AppColors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: selected
                            ? AppShadows.glow(AppColors.primary)
                            : null,
                      ),
                      child: Icon(
                        selected ? item.activeIcon : item.icon,
                        size: 22,
                        color: selected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color:
                            selected ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
