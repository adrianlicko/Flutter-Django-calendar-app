import 'dart:async';

import 'package:edge_detection_plus/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeDetectionPlus {
  static const MethodChannel _channel = MethodChannel('edge_detection');

  /// Call this method to scan the object edge in live camera.
  static Future<Map<Object?, Object?>> detectEdge(
    String saveTo, {
    bool canUseGallery = true,
    String androidScanTitle = "Scanning",
    String androidCropTitle = "Crop",
    String androidCropBlackWhiteTitle = "Black White",
    String androidCropReset = "Reset",
  }) async {
    return await _channel.invokeMethod('edge_detect', {
      'save_to': saveTo,
      'can_use_gallery': canUseGallery,
      'scan_title': androidScanTitle,
      'crop_title': androidCropTitle,
      'crop_black_white_title': androidCropBlackWhiteTitle,
      'crop_reset_title': androidCropReset,
    });
  }

  static Widget detectEdgeWidget(
    String saveTo, {
    bool canUseGallery = true,
    String androidScanTitle = "Scanning",
    String androidCropTitle = "Crop",
    String androidCropBlackWhiteTitle = "Black White",
    String androidCropReset = "Reset",
  }) {
    return EdgeDetectionWidget(
      saveTo: saveTo,
      canUseGallery: canUseGallery,
      androidScanTitle: androidScanTitle,
      androidCropTitle: androidCropTitle,
      androidCropBlackWhiteTitle: androidCropBlackWhiteTitle,
      androidCropReset: androidCropReset,
    );
  }

  /// Call this method to scan the object edge from a gallery image.
  static Future<bool> detectEdgeFromGallery(
    String saveTo, {
    String androidCropTitle = "Crop",
    String androidCropBlackWhiteTitle = "Black White",
    String androidCropReset = "Reset",
  }) async {
    return await _channel.invokeMethod('edge_detect_gallery', {
      'save_to': saveTo,
      'crop_title': androidCropTitle,
      'crop_black_white_title': androidCropBlackWhiteTitle,
      'crop_reset_title': androidCropReset,
      'from_gallery': true,
    });
  }
}
