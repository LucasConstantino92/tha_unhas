import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../admin/presentation/pages/admin_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/home_page.dart';
import '../../../booking/presentation/pages/bookings_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/navigation_provider.dart';

class MainScaffoldPage extends ConsumerWidget {
  const MainScaffoldPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final user = ref.watch(authProvider);
    final isAdmin = user?.role == 'admin';

    final pages = [
      const HomePage(),
      const BookingsPage(),
      const ProfilePage(),
      if (isAdmin) const AdminPage(),
    ];

    final navItems = [
      _NavItem(icon: Icons.home_rounded, label: 'HOME'),
      _NavItem(icon: Icons.calendar_today_rounded, label: 'AGENDA'),
      _NavItem(icon: Icons.person_rounded, label: 'PERFIL'),
      if (isAdmin) _NavItem(icon: Icons.admin_panel_settings_rounded, label: 'ADMIN'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _AnimatedBottomNav(
        items: navItems,
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

class _AnimatedBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnimatedBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final itemWidth = size.width / items.length;

    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // White background of the bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),
          // The animated "dot/bubble" that moves
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            top: 5,
            left: itemWidth * currentIndex,
            width: itemWidth,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryAccentColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The icons and text
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70,
            child: Row(
              children: List.generate(items.length, (index) {
                final isSelected = currentIndex == index;
                final item = items[index];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      transform: Matrix4.translationValues(0, isSelected ? -24 : 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? Colors.white : AppTheme.primaryAccentColor,
                            size: 26,
                          ),
                          if (!isSelected) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: AppTheme.primaryAccentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
