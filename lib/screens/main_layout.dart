import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import 'dashboard_screen.dart';
import 'recipes_screen.dart';
import 'machine_control_screen.dart';
import 'inventory_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: context.theme.background,
          body: Row(
            children: [
              Sidebar(),
              Expanded(
                child: Column(
                  children: [
                    TopBar(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: _buildCurrentPage(provider.currentPage),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage(NavPage page) {
    switch (page) {
      case NavPage.dashboard:
        return DashboardScreen(key: ValueKey('dashboard'));
      case NavPage.recipes:
        return RecipesScreen(key: ValueKey('recipes'));
      case NavPage.machineControl:
        return MachineControlScreen(key: ValueKey('machine'));
      case NavPage.inventory:
        return InventoryScreen(key: ValueKey('inventory'));
      case NavPage.analytics:
        return AnalyticsScreen(key: ValueKey('analytics'));
      case NavPage.settings:
        return SettingsScreen(key: ValueKey('settings'));
    }
  }
}
