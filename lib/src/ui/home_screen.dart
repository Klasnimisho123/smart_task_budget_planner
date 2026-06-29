import 'package:flutter/material.dart';
import 'package:smart_task_budget_planner/src/ui/budget_screen.dart';
import 'package:smart_task_budget_planner/src/ui/tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _navItems = [
    NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
    NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;
    final screens = const [TasksScreen(), BudgetScreen()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task & Budget Planner'),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isWide) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (value) => setState(() => _selectedIndex = value),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.task),
                      label: Text('Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_balance_wallet),
                      label: Text('Budget'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: screens[_selectedIndex]),
              ],
            );
          }

          return screens[_selectedIndex];
        },
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) => setState(() => _selectedIndex = value),
              destinations: _navItems,
            ),
    );
  }
}
