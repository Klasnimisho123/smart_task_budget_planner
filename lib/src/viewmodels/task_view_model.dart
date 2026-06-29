import 'package:flutter/foundation.dart';
import 'package:smart_task_budget_planner/src/models/task.dart';
import 'package:smart_task_budget_planner/src/services/api_service.dart';
import 'package:smart_task_budget_planner/src/services/firestore_service.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    loadRemoteTasks();
  }

  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService;
  final List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRemoteTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _tasks.clear();

    try {
      final remoteTasks = await _apiService.fetchTasks(limit: 6);
      _tasks.addAll(remoteTasks);
    } catch (e) {
      _error = 'Unable to load tasks from the API. Check your connection and retry.';
    }

    try {
      final savedTasks = await _firestoreService.loadSavedTasks();
      _tasks.addAll(savedTasks);
    } catch (e) {
      _error = _error == null
          ? 'Unable to load saved tasks from Firestore.'
          : '$_error\nUnable to load saved tasks from Firestore.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTask(Task task) {
    _tasks.insert(0, task);
    notifyListeners();
    _firestoreService.saveTask(task).catchError((_) {});
  }

  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    _firestoreService.deleteTask(id).catchError((_) {});
  }

  void toggleCompletion(int id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final current = _tasks[index];
    _tasks[index] = Task(
      id: current.id,
      title: current.title,
      description: current.description,
      dueDate: current.dueDate,
      isCompleted: !current.isCompleted,
      isRemote: current.isRemote,
    );
    notifyListeners();
  }
}
