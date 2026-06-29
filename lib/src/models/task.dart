class Task {
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.isRemote = false,
  });

  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  bool isCompleted;
  final bool isRemote;

  factory Task.fromJson(Map<String, dynamic> json) {
    final completed = json['completed'] as bool? ?? false;
    final id = json['id'] is int ? json['id'] as int : int.parse('${json['id']}');
    return Task(
      id: id,
      title: json['title'] as String? ?? 'Untitled task',
      description: completed
          ? 'Remote task completed from API'
          : 'Suggested remote task loaded from API',
      dueDate: DateTime.now().add(Duration(days: (id % 7) + 1)),
      isCompleted: completed,
      isRemote: true,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}') ?? 0,
      title: map['title'] as String? ?? 'Untitled task',
      description: map['description'] as String? ?? '',
      dueDate: _parseDueDate(map['dueDate']),
      isCompleted: map['isCompleted'] as bool? ?? false,
      isRemote: map['isRemote'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isRemote': isRemote,
    };
  }

  static DateTime _parseDueDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}
