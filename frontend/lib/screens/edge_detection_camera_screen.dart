import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/notifiers/error_notifier.dart';
import 'package:frontend/components/notifiers/info_notifier.dart';
import 'package:frontend/services/document_storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

enum ScannerEvents {
  VIEW_TYPE("scanner_view"),
  START_SCAN("start_scan"),
  DISPOSE_SCANNER("dispose_scanner"),
  SET_FLASH("set_flash"),
  ON("on"),
  DETECT_EDGE_WITH_CROP("detect_edge_with_crop"),
  DETECT_EDGE("detect_edge"),
  IMAGE_PATH("imagePath"),
  SUCCESS("success"),
  RECOGNIZED_TEXT("recognizedText");

  final String value;
  const ScannerEvents(this.value);
}

class EdgeDetectionCameraScreen extends StatefulWidget {
  const EdgeDetectionCameraScreen({super.key});

  @override
  State<EdgeDetectionCameraScreen> createState() => _EdgeDetectionCameraScreenState();
}

class _EdgeDetectionCameraScreenState extends State<EdgeDetectionCameraScreen> {
  MethodChannel? _methodChannel;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _hasCameraPermission = false;

  @override
  void dispose() {
    _stopScanner();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasCameraPermission = true;
      });
      _startScanner();
    } else {
      final result = await Permission.camera.request();
      setState(() {
        _hasCameraPermission = result.isGranted;
      });
    }
  }

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel("${ScannerEvents.VIEW_TYPE.value}_$id");
  }

  void _startScanner() {
    if (_hasCameraPermission) {
      _methodChannel?.invokeMethod(ScannerEvents.START_SCAN.value);
    }
  }

  void _stopScanner() {
    _methodChannel?.invokeMethod(ScannerEvents.DISPOSE_SCANNER.value);
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _methodChannel?.invokeMethod(ScannerEvents.SET_FLASH.value, {ScannerEvents.ON.value: _isFlashOn});
  }

  Future<void> _captureImage(bool autoCrop) async {
    if (_isProcessing || !_hasCameraPermission) return;

    setState(() {
      _isProcessing = true;
    });

    String eventName = autoCrop ? ScannerEvents.DETECT_EDGE_WITH_CROP.value : ScannerEvents.DETECT_EDGE.value;

    try {
      final tempDir = await getTemporaryDirectory();
      final imagePath = path.join(tempDir.path, 'document${DateTime.now().millisecondsSinceEpoch}.jpg');

      final result = await _methodChannel
          ?.invokeMethod<Map<dynamic, dynamic>>(eventName, {ScannerEvents.IMAGE_PATH.value: imagePath});

      if (result != null && result[ScannerEvents.SUCCESS.value] == true) {
        final savedImagePath = result[ScannerEvents.IMAGE_PATH.value] as String;
        final recognizedText = result[ScannerEvents.RECOGNIZED_TEXT.value] as String;

        final storageService = DocumentStorageService();
        await storageService.saveDocument(
          savedImagePath,
          name: 'Document ${DateTime.now().toString().substring(0, 16)}',
          recognizedText: recognizedText.isEmpty ? null : recognizedText,
        );

        if (mounted) {
          InfoNotifier.show(
            context: context,
            message: AppLocalizations.of(context)!.imageWasSavedToGallery,
            trailingButtonText: AppLocalizations.of(context)!.show,
            onPressed: () {
              if (_isFlashOn) {
                _toggleFlash();
                _isFlashOn = false;
              }
              context.push('/gallery');
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorNotifier.show(context: context, message: "$e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildCaptureButton({required void Function()? onPressed, required String text}) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
        shape: WidgetStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        )),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCameraPermission) {
      _checkCameraPermission();
      return AppScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.noCameraPermission),
              TextButton(
                onPressed: openAppSettings,
                child: Text(AppLocalizations.of(context)!.openSettings),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      actions: [
        IconButton(
          icon: Icon(_isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
          onPressed: _toggleFlash,
        ),
      ],
      body: Stack(
        children: [
          AndroidView(
            viewType: ScannerEvents.VIEW_TYPE.value,
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParamsCodec: const StandardMessageCodec(),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCaptureButton(
                    onPressed: () => _captureImage(false),
                    text: AppLocalizations.of(context)!.capture,
                  ),
                  _buildCaptureButton(
                    onPressed: () => _captureImage(true),
                    text: AppLocalizations.of(context)!.captureAndCrop,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
