import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/notifiers/error_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/document_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class DocumentStorageService {
  static const String _documentsKey = 'scanned_documents';
  final Uuid _uuid = const Uuid();
  
  Future<DocumentModel> saveDocument(String sourcePath, {String? name}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final documentsDir = Directory('${appDir.path}/scanned_documents');
    
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    
    final id = _uuid.v4();
    final ext = sourcePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final destinationPath = '${documentsDir.path}/$fileName';
    
    final File sourceFile = File(sourcePath);
    final File newFile = await sourceFile.copy(destinationPath);
    
    final document = DocumentModel(
      id: id,
      path: newFile.path,
      createdAt: DateTime.now(),
      name: name ?? 'Document ${DateTime.now().toString().substring(0, 16)}',
    );
    
    await _saveDocumentMetadata(document);
    return document;
  }
  
  Future<List<DocumentModel>> getAllDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getStringList(_documentsKey) ?? [];
    
    return documentsJson
      .map((json) => DocumentModel.fromJson(jsonDecode(json)))
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  Future<bool> deleteDocument(BuildContext context, String id) async {
    final documents = await getAllDocuments();
    final documentIndex = documents.indexWhere((doc) => doc.id == id);
    
    if (documentIndex == -1) {
      ErrorNotifier.show(context: context, message: AppLocalizations.of(context)!.failedToDeleteTodo);
      return false;
    }
    
    final documentToDelete = documents[documentIndex];
    final file = File(documentToDelete.path);
    if (await file.exists()) {
      await file.delete();
    }
    
    final updatedDocuments = documents.where((doc) => doc.id != id).toList();
    await _saveDocumentsList(updatedDocuments);
    return true;
  }
  
  Future<void> _saveDocumentMetadata(DocumentModel document) async {
    final documents = await getAllDocuments();
    documents.add(document);
    await _saveDocumentsList(documents);
  }
  
  Future<void> _saveDocumentsList(List<DocumentModel> documents) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = documents.map((doc) => jsonEncode(doc.toJson())).toList();
    await prefs.setStringList(_documentsKey, documentsJson);
  }
}