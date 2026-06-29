import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smart_task_budget_planner/src/models/budget_item.dart';
import 'package:smart_task_budget_planner/src/ui/add_budget_item_dialog.dart';
import 'package:smart_task_budget_planner/src/viewmodels/budget_view_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  double _currentExpenseRatio = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0,
      upperBound: 1,
    );
    _progressController.value = 0;
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _animateProgress(double target) {
    final clampedTarget = target.clamp(0.0, 1.0);
    if (_currentExpenseRatio == clampedTarget) return;
    _currentExpenseRatio = clampedTarget;
    _progressController.value = 0;
    _progressController.animateTo(clampedTarget, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BudgetViewModel>();
    final totalIncome = model.totalIncome;
    final totalExpense = model.totalExpense;
    final balance = model.balance;
    final expenseRatio = totalIncome == 0 ? 0.0 : (totalExpense / totalIncome).clamp(0.0, 1.0);

    _animateProgress(expenseRatio);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            return Column(
              children: [
                if (model.isLoading) const LinearProgressIndicator(minHeight: 4),
                if (model.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      model.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: balance >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Budget Summary',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Income, expense, and balance calculations are managed by a ViewModel with Provider.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          if (!isWide)
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Lottie.network(
                                'https://assets9.lottiefiles.com/packages/lf20_gzqvntnj.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BudgetStat(label: 'Income', value: totalIncome),
                          _BudgetStat(label: 'Expense', value: totalExpense),
                          _BudgetStat(label: 'Balance', value: balance),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Expense ratio', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                      const SizedBox(height: 10),
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressController.value,
                            minHeight: 12,
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text('${(expenseRatio * 100).toStringAsFixed(0)}% of income spent', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isWide
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3,
                          ),
                          itemCount: model.items.length,
                          itemBuilder: (context, index) {
                            return _BudgetCard(
                              item: model.items[index],
                              onDelete: () => model.deleteBudgetItem(model.items[index].id),
                            );
                          },
                        )
                      : ListView.separated(
                          itemCount: model.items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _BudgetCard(
                              item: model.items[index],
                              onDelete: () => model.deleteBudgetItem(model.items[index].id),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final viewModel = context.read<BudgetViewModel>();
          final result = await showDialog<BudgetItem>(
            context: context,
            builder: (_) => const AddBudgetItemDialog(),
          );
          if (result != null) {
            viewModel.addBudgetItem(result);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black)),
        const SizedBox(height: 6),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.item,
    required this.onDelete,
  });

  final BudgetItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.category.color.withAlpha(51),
            child: Icon(item.category.icon, color: item.category.color),
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
    );
  }
}
