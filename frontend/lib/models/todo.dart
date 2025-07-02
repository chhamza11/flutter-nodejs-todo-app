class Todo {
  final int id;
  String title;
  bool isCompleted;
  bool isDeleted;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.isDeleted,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
