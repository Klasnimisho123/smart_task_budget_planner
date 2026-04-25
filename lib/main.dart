import 'dart:math';
import 'package:flutter/material.dart';

enum Category {
  food(label: 'Food', icon: Icons.fastfood, color: Colors.orange),
  transport(label: 'Transport', icon: Icons.directions_car, color: Colors.blue),
  entertainment(
    label: 'Entertainment',
    icon: Icons.movie,
    color: Colors.purple,
  ),
  utilities(label: 'Utilities', icon: Icons.light_mode, color: Colors.green),
  salary(label: 'Salary', icon: Icons.work, color: Colors.green),
  others(label: 'Others', icon: Icons.category, color: Colors.grey);

  const Category({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;
}

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  bool isCompleted;

  Task(this.id, this.title, this.description, this.dueDate, this.isCompleted);
}

class BudgetItem {
  final int id;
  final String title;
  final double amount;
  final Category category;
  final bool isIncome;

  BudgetItem(this.id, this.title, this.amount, this.category, this.isIncome);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Task & Budget Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Task> _tasks = [
    Task(
      1,
      'Complete Flutter project',
      'Finish the midterm project',
      DateTime.now().add(const Duration(days: 2)),
      false,
    ),
    Task(
      2,
      'Buy groceries',
      'Weekly shopping',
      DateTime.now().add(const Duration(days: 1)),
      false,
    ),
    Task(
      3,
      'Study for exam',
      'Review notes',
      DateTime.now().add(const Duration(days: 5)),
      true,
    ),
  ];

  final List<BudgetItem> _budgetItems = [
    BudgetItem(1, 'Salary', 3000.0, Category.salary, true),
    BudgetItem(2, 'Groceries', 200.0, Category.food, false),
    BudgetItem(3, 'Electricity', 100.0, Category.utilities, false),
    BudgetItem(4, 'Freelance', 500.0, Category.others, true),
  ];

  void _addTask(Task task) {
    setState(() => _tasks.add(task));
  }

  void _deleteTask(int id) {
    setState(() => _tasks.removeWhere((task) => task.id == id));
  }

  void _toggleTaskCompletion(int id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _addBudgetItem(BudgetItem item) {
    setState(() => _budgetItems.add(item));
  }

  void _deleteBudgetItem(int id) {
    setState(() => _budgetItems.removeWhere((item) => item.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task & Budget Planner'),
        elevation: 0,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            TasksScreen(
              tasks: _tasks,
              onAddTask: _addTask,
              onDeleteTask: _deleteTask,
              onToggleTask: _toggleTaskCompletion,
            ),
            BudgetScreen(
              items: _budgetItems,
              onAddItem: _addBudgetItem,
              onDeleteItem: _deleteBudgetItem,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onDeleteTask,
    required this.onToggleTask,
  });

  final List<Task> tasks;
  final Function(Task) onAddTask;
  final Function(int) onDeleteTask;
  final Function(int) onToggleTask;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.05,
      vertical: 16,
    );

    return Scaffold(
      body: ListView(
        padding: padding,
        children: [
          Text(
            'Tasks',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty) const Text('No tasks found'),
          ...tasks.map(
            (task) => Dismissible(
              key: ValueKey(task.id),
              onDismissed: (_) => onDeleteTask(task.id),
              background: Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.only(right: 24.0),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggleTask(task.id),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    '${task.description}\nDue: ${task.dueDate.toLocal().toString().split(' ')[0]}',
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<Task>(
            context: context,
            builder: (_) => const AddTaskDialog(),
          );
          if (result != null) onAddTask(result);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onDeleteItem,
  });

  final List<BudgetItem> items;
  final Function(BudgetItem) onAddItem;
  final Function(int) onDeleteItem;

  double get _totalIncome => items
      .where((item) => item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get _totalExpense => items
      .where((item) => !item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);
  double get _balance => _totalIncome - _totalExpense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.05,
      vertical: 16,
    );

    return Scaffold(
      body: ListView(
        padding: padding,
        children: [
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Overview',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Income: \$${_totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(color: cs.onPrimaryContainer),
                      ),
                      Text(
                        'Expense: \$${_totalExpense.toStringAsFixed(2)}',
                        style: TextStyle(color: cs.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Balance: \$${_balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _balance >= 0 ? cs.onPrimaryContainer : cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transactions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty) const Text('No transactions found'),
          ...items.map(
            (item) => Dismissible(
              key: ValueKey(item.id),
              onDismissed: (_) => onDeleteItem(item.id),
              background: Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.only(right: 24.0),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.category.color.withValues(alpha: 0.3),
                    child: Icon(
                      item.category.icon,
                      color: item.category.color,
                      size: 20,
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.category.label),
                  trailing: Text(
                    '${item.isIncome ? '+' : '-'}\$${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: item.isIncome ? cs.primary : cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<BudgetItem>(
            context: context,
            builder: (_) => const AddBudgetItemDialog(),
          );
          if (result != null) onAddItem(result);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Due Date: '),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                  child: Text(_dueDate.toLocal().toString().split(' ')[0]),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final description = _descriptionController.text.trim();
            if (title.isEmpty || description.isEmpty) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Please fill in all fields'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }
            final task = Task(
              Random().nextInt(9999),
              title,
              description,
              _dueDate,
              false,
            );
            Navigator.of(context).pop(task);
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}

class AddBudgetItemDialog extends StatefulWidget {
  const AddBudgetItemDialog({super.key});

  @override
  State<AddBudgetItemDialog> createState() => _AddBudgetItemDialogState();
}

class _AddBudgetItemDialogState extends State<AddBudgetItemDialog> {
  Category selectedCategory = Category.food;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isIncome = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Budget Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Type: '),
                Switch(
                  value: _isIncome,
                  onChanged: (value) => setState(() => _isIncome = value),
                ),
                Text(_isIncome ? 'Income' : 'Expense'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children:
                  (_isIncome
                          ? [Category.salary, Category.others]
                          : Category.values
                                .where((c) => c != Category.salary)
                                .toList())
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item.label),
                          selected: item.label == selectedCategory.label,
                          onSelected: (_) =>
                              setState(() => selectedCategory = item),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final amountText = _amountController.text.trim();
            if (title.isEmpty || amountText.isEmpty) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Please fill in all fields'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }
            final amount = double.tryParse(amountText);
            if (amount == null || amount <= 0) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Please enter a valid amount'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }
            final item = BudgetItem(
              Random().nextInt(9999),
              title,
              amount,
              selectedCategory,
              _isIncome,
            );
            Navigator.of(context).pop(item);
          },
          child: const Text('Add Item'),
        ),
      ],
    );
  }
}
