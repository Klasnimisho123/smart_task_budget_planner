import 'package:flutter/material.dart';

enum Category {
  food(label: 'Food', icon: Icons.fastfood, color: Colors.orange),
  transport(label: 'Transport', icon: Icons.directions_car, color: Colors.blue),
  entertainment(label: 'Entertainment', icon: Icons.movie, color: Colors.purple),
  utilities(label: 'Utilities', icon: Icons.light_mode, color: Colors.green),
  salary(label: 'Salary', icon: Icons.work, color: Colors.teal),
  others(label: 'Others', icon: Icons.category, color: Colors.grey);

  const Category({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  static Category fromLabel(String label) {
    return Category.values.firstWhere(
      (category) => category.label == label,
      orElse: () => Category.others,
    );
  }
}

class BudgetItem {
  BudgetItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
  });

  final int id;
  final String title;
  final double amount;
  final Category category;
  final bool isIncome;

  factory BudgetItem.fromMap(Map<String, dynamic> map) {
    return BudgetItem(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}') ?? 0,
      title: map['title'] as String? ?? 'Budget item',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: Category.fromLabel(map['category'] as String? ?? Category.others.label),
      isIncome: map['isIncome'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.label,
      'isIncome': isIncome,
    };
  }
}
