import 'package:dio/dio.dart';
import 'package:smart_task_budget_planner/src/models/task.dart';

class ApiService {
  ApiService([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(
          baseUrl: 'https://jsonplaceholder.typicode.com',
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ));

  final Dio _dio;

  Future<List<Task>> fetchTasks({int limit = 6}) async {
    final response = await _dio.get('/todos', queryParameters: {'_limit': limit});
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load tasks from API');
  }
}
