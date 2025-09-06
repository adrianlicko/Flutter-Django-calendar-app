class DocumentModel {
  final String id;
  final String path;
  final DateTime createdAt;
  final String? name;
  final String? text;
  
  DocumentModel({
    required this.id,
    required this.path,
    required this.createdAt,
    this.name,
    this.text,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
    'name': name,
    'text': text,
  };
  
  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json['id'],
    path: json['path'],
    createdAt: DateTime.parse(json['createdAt']),
    name: json['name'],
    text: json['text'],
  );
}