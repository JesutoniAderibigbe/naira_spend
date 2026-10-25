import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation for Home, Budgets and Insights.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              key: ValueKey('nav.home'),
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              key: ValueKey('nav.budgets'),
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Budgets',
            ),
            NavigationDestination(
              key: ValueKey('nav.insights'),
              icon: Icon(Icons.bar_chart),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}
