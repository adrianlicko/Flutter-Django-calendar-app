class TodoModel {
  final DateTime? createdAt;
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;

  TodoModel({
    this.createdAt, // backend will handle this
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });
}