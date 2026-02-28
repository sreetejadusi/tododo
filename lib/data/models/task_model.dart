enum TaskPriority { low, medium, high }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == json['priority'],
        orElse: () => TaskPriority.low,
      ),
      dueDate: DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
