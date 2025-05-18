import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/notifiers/error_notifier.dart';
import 'package:frontend/components/notifiers/info_notifier.dart';
import 'package:frontend/models/document_model.dart';
import 'package:frontend/screens/loading_screen.dart';
import 'package:frontend/services/document_storage_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final DocumentStorageService _storageService = DocumentStorageService();
  bool _isLoading = true;
  List<DocumentModel> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docs = await _storageService.getAllDocuments();
      setState(() {
        _documents = docs;
      });
    } catch (e) {
      if (mounted) {
        ErrorNotifier.show(
          context: context,
          message: AppLocalizations.of(context)!.failedToLoadDocuments,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDocument(String id) async {
    try {
      await _storageService.deleteDocument(context, id);
      _loadDocuments();
    } catch (e) {
      if (mounted) {
        ErrorNotifier.show(
          context: context,
          message: AppLocalizations.of(context)!.failedToDeleteDocument,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: _isLoading
          ? const LoadingScreen()
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.youHaveNoDocuments),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.push('/scan'),
                        child: Text(
                          AppLocalizations.of(context)!.scan,
                        ),
                      )
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _DocumentViewScreen(document: doc),
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(doc.path),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 40),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                onPressed: () => _deleteDocument(doc.id),
                                constraints: const BoxConstraints.tightFor(
                                  width: 30,
                                  height: 30,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              color: Colors.black.withOpacity(0.5),
                              child: Text(
                                doc.name ?? '${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _DocumentViewScreen extends StatelessWidget {
  final DocumentModel document;

  const _DocumentViewScreen({required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name ?? 'Document'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(File(document.path)),
            ),
          ),
          if (document.text != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.recognizedText}:",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: document.text!));
                          InfoNotifier.show(context: context, message: AppLocalizations.of(context)!.textWasCopied);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(document.text!),
                ],
              ),
            )
        ],
      ),
    );
  }
}
