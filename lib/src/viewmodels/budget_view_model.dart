import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:smart_task_budget_planner/src/models/budget_item.dart';
import 'package:smart_task_budget_planner/src/services/firestore_service.dart';

class BudgetViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final List<BudgetItem> _items = [
    BudgetItem(
      id: 1,
      title: 'Salary',
      amount: 3200.0,
      category: Category.salary,
      isIncome: true,
    ),
    BudgetItem(
      id: 2,
      title: 'Groceries',
      amount: 250.0,
      category: Category.food,
      isIncome: false,
    ),
    BudgetItem(
      id: 3,
      title: 'Utilities',
      amount: 140.0,
      category: Category.utilities,
      isIncome: false,
    ),
    BudgetItem(
      id: 4,
      title: 'Freelance Work',
      amount: 600.0,
      category: Category.others,
      isIncome: true,
    ),
  ];

  bool _isLoading = false;
  String? _error;

  BudgetViewModel({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    loadBudgetItems();
  }

  List<BudgetItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome =>
      _items.where((item) => item.isIncome).fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense =>
      _items.where((item) => !item.isIncome).fold(0.0, (sum, item) => sum + item.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadBudgetItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteItems = await _firestoreService.loadBudgetItems();
      if (remoteItems.isNotEmpty) {
        _items
          ..clear()
          ..addAll(remoteItems);
      }
    } catch (_) {
      _error = 'Unable to load budget data from Firestore. Showing local sample items.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addBudgetItem(BudgetItem item) {
    _items.insert(0, item);
    notifyListeners();
    _firestoreService.saveBudgetItem(item).catchError((_) {});
  }

  void deleteBudgetItem(int id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    _firestoreService.deleteBudgetItem(id).catchError((_) {});
  }
}
