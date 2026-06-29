import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_task_budget_planner/src/models/budget_item.dart';
import 'package:smart_task_budget_planner/src/models/task.dart';

class FirestoreService {
  FirestoreService()
      : _isAvailable = Firebase.apps.isNotEmpty,
        _firestore = Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  final FirebaseFirestore? _firestore;
  final bool _isAvailable;
  final String _budgetCollection = 'budget_items';
  final String _taskCollection = 'saved_tasks';

  Future<List<BudgetItem>> loadBudgetItems() async {
    if (!_isAvailable || _firestore == null) return [];
    final snapshot = await _firestore.collection(_budgetCollection).orderBy('id', descending: true).get();
    return snapshot.docs.map((doc) => BudgetItem.fromMap(doc.data())).toList();
  }

  Future<void> saveBudgetItem(BudgetItem item) async {
    if (!_isAvailable || _firestore == null) return;
    await _firestore.collection(_budgetCollection).doc(item.id.toString()).set(item.toMap());
  }

  Future<void> deleteBudgetItem(int id) async {
    if (!_isAvailable || _firestore == null) return;
    await _firestore.collection(_budgetCollection).doc(id.toString()).delete();
  }

  Future<List<Task>> loadSavedTasks() async {
    if (!_isAvailable || _firestore == null) return [];
    final snapshot = await _firestore.collection(_taskCollection).orderBy('dueDate').get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  Future<void> saveTask(Task task) async {
    if (!_isAvailable || _firestore == null) return;
    await _firestore.collection(_taskCollection).doc(task.id.toString()).set(task.toMap());
  }

  Future<void> deleteTask(int id) async {
    if (!_isAvailable || _firestore == null) return;
    await _firestore.collection(_taskCollection).doc(id.toString()).delete();
  }
}
