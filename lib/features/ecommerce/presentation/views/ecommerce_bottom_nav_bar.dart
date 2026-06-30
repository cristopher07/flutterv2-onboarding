import 'package:flutter/material.dart';

class EcommerceBottomNavBar extends StatelessWidget {
  const EcommerceBottomNavBar({
    required this.currentIndex,
    required this.onItemSelected,
    this.isAdmin = false,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final bool isAdmin;

  static const _baseItems = [
    _EcommerceNavItem(
      label: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _EcommerceNavItem(
      label: 'Categories',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
    ),
    _EcommerceNavItem(
      label: 'Stores',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
    ),
    _EcommerceNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  static const _adminItem = _EcommerceNavItem(
    label: 'Administrar',
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2,
  );

  @override
  Widget build(BuildContext context) {
    final items = isAdmin ? [..._baseItems, _adminItem] : _baseItems;

    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8EAF0))),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onItemSelected(index),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 58,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 22,
                        color:
                            isSelected
                                ? const Color(0xFF067DF7)
                                : const Color(0xFFC7CBD6),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? const Color(0xFF202124)
                                  : const Color(0xFF8E929D),
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _EcommerceNavItem {
  const _EcommerceNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
