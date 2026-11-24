
import 'package:flutter/material.dart';

import 'package:skill_track/screens/manage_subjects_screen.dart';
import 'package:skill_track/screens/settings_screen.dart';

import 'dashboard_screen.dart';
import 'deep_focus_screen.dart';
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

  static const Color primary = Color(0xFF16845B);
  static const Color background = Color(0xFFF6F8F7);

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
    Icons.home_rounded,
    Icons.timer_rounded,
    Icons.route_rounded,
    Icons.edit_note_rounded,
    Icons.style_rounded,
    Icons.bar_chart_rounded,
  ];

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void openManageSubjects() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManageSubjectsScreen(),
      ),
    );
  }

  void openDeepFocus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DeepFocusScreen(),
      ),
    );
  }

  void openUserGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserGuideScreen(),
      ),
    );
  }

  void handleMenuSelection(String value) {
    switch (value) {
      case 'subjects':
        openManageSubjects();
        break;
      case 'deep_focus':
        openDeepFocus();
        break;
      case 'guide':
        openUserGuide();
        break;
      case 'settings':
        openSettings();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 39,
              width: 39,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F3EA),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FocusTech',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF18352A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Learn. Focus. Grow.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ONE MENU BUTTON INSTEAD OF FOUR ACTION BUTTONS
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF53665C),
              size: 25,
            ),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'subjects',
                child: _MenuItem(
                  icon: Icons.library_books_outlined,
                  title: 'Manage Subjects',
                ),
              ),
              const PopupMenuItem(
                value: 'deep_focus',
                child: _MenuItem(
                  icon: Icons.center_focus_strong_rounded,
                  title: 'Deep Focus',
                ),
              ),
              const PopupMenuItem(
                value: 'guide',
                child: _MenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'User Guide',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
        ],
      ),

      // MAIN CONTENT
      body: IndexedStack(
        index: index,
        children: pages,
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 8, 5, 5),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 68,
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFFE2F2E9),
                labelTextStyle:
                    WidgetStateProperty.resolveWith<TextStyle>(
                  (states) {
                    final selected =
                        states.contains(WidgetState.selected);

                    return TextStyle(
                      fontSize: 10,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: selected
                          ? primary
                          : Colors.grey.shade600,
                    );
                  },
                ),
                iconTheme:
                    WidgetStateProperty.resolveWith<IconThemeData>(
                  (states) {
                    final selected =
                        states.contains(WidgetState.selected);

                    return IconThemeData(
                      size: 22,
                      color: selected
                          ? primary
                          : Colors.grey.shade500,
                    );
                  },
                ),
              ),
              child: NavigationBar(
                selectedIndex: index,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (value) {
                  setState(() {
                    index = value;
                  });
                },
                destinations: [
                  for (var i = 0; i < labels.length; i++)
                    NavigationDestination(
                      icon: Icon(icons[i]),
                      selectedIcon: Icon(icons[i]),
                      label: labels[i],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// APP BAR MENU ITEM
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color: const Color(0xFF16845B),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF18352A),
          ),
        ),
      ],
    );
  }
}
