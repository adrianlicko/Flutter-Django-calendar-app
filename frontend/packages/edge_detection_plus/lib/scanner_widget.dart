import 'dart:io';
import 'package:edge_detection_plus/scanner_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  EventChannel? _eventChannel;
  MethodChannel? _methodChannel;

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('scanner_view_$id');
    _eventChannel = EventChannel('scanner_events_$id');

    _eventChannel?.receiveBroadcastStream().listen((dynamic event) {
      print("Scanner Widget received event: $event"); // Debug print
      if (event is Map && event['qrDetected'] != null) {
        print("QR Detected in Scanner: ${event['qrValue']}"); // Debug print
      }
    }, onError: (error) {
      print("Scanner Widget error: $error");
    });
  }

  @override
  void dispose() {
    // ScannerController.disposeScanner();
    _methodChannel?.invokeMethod('dispose_scanner');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Platform.isAndroid
          ? AndroidView(
              viewType: 'scanner_view',
              creationParams: {},
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            )
          : Platform.isIOS
              ? UiKitView(
                  viewType: 'scanner_view',
                  creationParams: {},
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: _onPlatformViewCreated,
                )
              : const Text('Platform not supported'),
    );
  }
}
