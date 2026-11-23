
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'focus_screen.dart';
import 'roadmap_screen.dart';
import 'journal_screen.dart';
import 'revision_screen.dart';
import 'analytics_screen.dart';
import 'user_guide_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  late final List<Widget> pages = [
    DashboardScreen(
      onStartFocus: () {
        setState(() => index = 1);
      },
    ),
    const FocusScreen(),
    const RoadmapScreen(),
    const JournalScreen(),
    const RevisionScreen(),
    const AnalyticsScreen(),
  ];

  final List<String> labels = const [
    'Home',
    'Focus',
    'Roadmap',
    'Journal',
    'Revise',
    'Stats',
  ];

  final List<IconData> icons = const [
    Icons.home_outlined,
    Icons.timer_outlined,
    Icons.route_outlined,
    Icons.edit_note,
    Icons.style_outlined,
    Icons.bar_chart,
  ];

  void openUserGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserGuideScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FocusTech',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'User Guide',
            icon: const Icon(Icons.help_outline),
            onPressed: openUserGuide,
          ),
        ],
      ),

      body: IndexedStack(
        index: index,
        children: pages,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: [
          for (var i = 0; i < labels.length; i++)
            NavigationDestination(
              icon: Icon(icons[i]),
              label: labels[i],
            ),
        ],
      ),
    );
  }
}
