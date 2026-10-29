import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuidarte_app/core/theme/app_colors.dart';
import 'package:cuidarte_app/providers/caregiver_provider.dart';
import 'package:cuidarte_app/providers/client_dashboard_provider.dart';
import 'package:cuidarte_app/providers/resource_provider.dart';
import 'package:cuidarte_app/providers/shop_provider.dart';
import 'package:cuidarte_app/providers/visit_provider.dart';
import 'package:cuidarte_app/providers/workshop_provider.dart';

import '../home/home_dashboard_screen.dart';
import '../caregivers/caregivers_list_screen.dart';
import '../workshops/workshops_resources_screen.dart';
import '../shop/shop_catalog_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadClientData();
      }
    });
  }

  void _loadClientData() {
    context.read<ClientDashboardProvider>().load();
    context.read<CaregiverProvider>().load();
    context.read<WorkshopProvider>().load();
    context.read<ResourceProvider>().load();
    context.read<ShopProvider>().loadProducts();
    context.read<ShopProvider>().loadOrders();
    context.read<VisitProvider>().loadMyVisits();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<ShopProvider>().cartCount;

    final screens = [
      HomeDashboardScreen(onNavigateTab: _onTabSelected),
      const CaregiversListScreen(),
      const WorkshopsResourcesScreen(),
      const ShopCatalogScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Cuidadores',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Talleres',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.storefront_outlined),
                  if (cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.rejected,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.storefront_rounded),
              label: 'Tienda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
