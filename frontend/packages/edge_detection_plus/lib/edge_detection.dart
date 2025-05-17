import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeDetection {
  static const MethodChannel _channel = const MethodChannel('edge_detection');

  /// Instead of returning a Future<Widget>, this factory returns a widget that
  /// asynchronously invokes the edge detection and then updates its state.
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
}

class EdgeDetectionWidget extends StatefulWidget {
  final String saveTo;
  final bool canUseGallery;
  final String androidScanTitle;
  final String androidCropTitle;
  final String androidCropBlackWhiteTitle;
  final String androidCropReset;

  const EdgeDetectionWidget({
    Key? key,
    required this.saveTo,
    this.canUseGallery = true,
    this.androidScanTitle = "Scanning",
    this.androidCropTitle = "Crop",
    this.androidCropBlackWhiteTitle = "Black White",
    this.androidCropReset = "Reset",
  }) : super(key: key);

  @override
  _EdgeDetectionWidgetState createState() => _EdgeDetectionWidgetState();
}

class _EdgeDetectionWidgetState extends State<EdgeDetectionWidget> {
  bool? _detectionSuccess;
  bool _onFullscreen = true;

  @override
  void initState() {
    super.initState();
    _onFullscreen ? _startEdgeDetectionOnFullscreen() : _startEdgeDetectionInWindowed();
  }

  void _startEdgeDetectionOnFullscreen() async {
    try {
      bool success = await EdgeDetection._channel.invokeMethod(
        'edge_detect',
        {
          'save_to': widget.saveTo,
          'can_use_gallery': widget.canUseGallery,
          'scan_title': widget.androidScanTitle,
          'crop_title': widget.androidCropTitle,
          'crop_black_white_title': widget.androidCropBlackWhiteTitle,
          'crop_reset_title': widget.androidCropReset,
        },
      );
      if (mounted) {
        setState(() {
          _detectionSuccess = success;
        });
      }
    } catch (e) {
      if (mounted) {
        print(e);
        setState(() {
          _detectionSuccess = false;
        });
      }
    }
  }

  void _startEdgeDetectionInWindowed() {}

  @override
  Widget build(BuildContext context) {
    if (_detectionSuccess == null) {
      // Still processing, show a loading indicator
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Text(
        _detectionSuccess! ? 'Edge Detection Successful' : 'Edge Detection Failed',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
