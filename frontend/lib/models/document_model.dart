class DocumentModel {
  final String id;
  final String path;
  final DateTime createdAt;
  final String? name;
  
  DocumentModel({
    required this.id,
    required this.path,
    required this.createdAt,
    this.name,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
  };
  
  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json['id'],
    path: json['path'],
    createdAt: DateTime.parse(json['createdAt']),
    name: json['name'],
  );
}