import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smart_task_budget_planner/src/models/budget_item.dart';

class AddBudgetItemDialog extends StatefulWidget {
  const AddBudgetItemDialog({super.key});

  @override
  State<AddBudgetItemDialog> createState() => _AddBudgetItemDialogState();
}

class _AddBudgetItemDialogState extends State<AddBudgetItemDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  Category _selectedCategory = Category.food;
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
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Type:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: _isIncome,
                  onSelected: (value) => setState(() => _isIncome = value),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: !_isIncome,
                  onSelected: (value) => setState(() => _isIncome = !value),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: (_isIncome ? [Category.salary, Category.others] : Category.values.where((c) => c != Category.salary).toList())
                  .map(
                    (category) => ChoiceChip(
                      label: Text(category.label),
                      selected: category == _selectedCategory,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final amount = double.tryParse(_amountController.text.trim());
            if (title.isEmpty || amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid values')));
              return;
            }
            Navigator.of(context).pop(
              BudgetItem(
                id: Random().nextInt(100000),
                title: title,
                amount: amount,
                category: _selectedCategory,
                isIncome: _isIncome,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
