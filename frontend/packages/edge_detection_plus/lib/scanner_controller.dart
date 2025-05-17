import 'package:flutter/services.dart';

class ScannerController {
  static const _channel = MethodChannel('scanner_view_0');

  static Future<void> disposeScanner() async {
    await _channel.invokeMethod('dispose_scanner');
  }

  static Future<void> startScan() async {
    await _channel.invokeMethod('start_scan');
  }

  static Future<void> stopScan() async {
    await _channel.invokeMethod('stop_scan');
  }
}
