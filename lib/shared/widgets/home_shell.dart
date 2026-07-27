import 'package:flutter/material.dart';

/// Persistent bottom-navigation shell used by GoRouter's StatefulShellRoute.
/// Keeps each tab's navigation stack alive when switching tabs.
class HomeShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Асосӣ'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Дарсҳо'),
          NavigationDestination(icon: Icon(Icons.terminal_rounded), label: 'Playground'),
          NavigationDestination(icon: Icon(Icons.leaderboard_rounded), label: 'Рейтинг'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профил'),
        ],
      ),
    );
  }
}
