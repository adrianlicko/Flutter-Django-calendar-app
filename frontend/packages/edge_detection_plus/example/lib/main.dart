// import 'dart:io';
// import 'package:edge_detection_plus/edge_detection_plus.dart';
// import 'package:edge_detection_plus/scanner_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(EdgeDetectionApp());
// }

// class EdgeDetectionApp extends StatelessWidget {
//   const EdgeDetectionApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Edge Detection Plugin Example',
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String? _imagePath;

//   Future<String> _generateFilePath() async {
//     final directory = await getApplicationSupportDirectory();
//     return join(directory.path, "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
//   }

//   void _navigateToScanner(BuildContext context) async {
//     bool isCameraGranted = await Permission.camera.request().isGranted;
//     if (!isCameraGranted) {
//       isCameraGranted = await Permission.camera.request() == PermissionStatus.granted;
//     }

//     if (!isCameraGranted) {
//       // Have not permission to camera
//       return;
//     }

//     // Generate filepath for saving
//     String imagePath = join((await getApplicationSupportDirectory()).path,
//         "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

//     // bool success = false;
//     Map<Object?, Object?> result = {};

//     try {
//       //Make sure to await the call to detectEdge.
//       result = await EdgeDetectionPlus.detectEdge(
//         imagePath,
//         canUseGallery: true,
//         androidScanTitle: 'Scanning', // use custom localizations for android
//         androidCropTitle: 'Crop',
//         androidCropBlackWhiteTitle: 'Black White',
//         androidCropReset: 'Reset',
//       );
//       print("success: $result");
//     } catch (e) {
//       print(e);
//     }

//     if (!mounted) return;

//     setState(() {
//       if (result['success'] == true) {
//         _imagePath = imagePath;
//       }
//     });
//   }

//   void _navigateToGalleryScanner(BuildContext context) async {
//     String saveTo = await _generateFilePath();
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (BuildContext context) => GalleryScannerScreen(saveTo: saveTo),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Plugin example app'),
//       ),
//       // body: Center(
//       //   child: Column(
//       //     mainAxisAlignment: MainAxisAlignment.center,
//       //     children: [
//       //       ElevatedButton(
//       //         onPressed: () => _navigateToScanner(context),
//       //         child: Text('Scan'),
//       //       ),
//       //       SizedBox(height: 20),
//       //       ElevatedButton(
//       //         onPressed: () => _navigateToGalleryScanner(context),
//       //         child: Text('Upload'),
//       //       ),
//       //       SizedBox(height: 20),
//       //       Text('Cropped image path:'),
//       //       if (_imagePath != null)
//       //         Padding(
//       //           padding: const EdgeInsets.all(8.0),
//       //           child: Image.file(
//       //             File(_imagePath ?? ''),
//       //           ),
//       //         ),
//       //     ],
//       //   ),
//       // ),
//       body: Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         child: ScannerWidget()),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.camera),
//             label: 'Scan',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.photo),
//             label: 'Gallery',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ScannerScreen extends StatelessWidget {
//   final String saveTo;
//   const ScannerScreen({Key? key, required this.saveTo}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Edge Detection")),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.camera_alt),
//             label: "Scan",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.check),
//             label: "Done",
//           ),
//         ],
//       ),
//       body: EdgeDetectionPlus.detectEdgeWidget(
//         saveTo,
//         canUseGallery: true,
//         androidScanTitle: "Scanning",
//         androidCropTitle: "Crop",
//         androidCropBlackWhiteTitle: "Black White",
//       ),
//     );
//   }
// }

// class GalleryScannerScreen extends StatelessWidget {
//   final String saveTo;
//   const GalleryScannerScreen({Key? key, required this.saveTo}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Edge Detection From Gallery")),
//       body: Center(
//         child: Text("Implement gallery-based scanning here."),
//       ),
//     );
//   }
// }

// example/lib/main.dart
import 'dart:io';
import 'package:edge_detection_plus/edge_detection_plus.dart';
import 'package:edge_detection_plus/scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(EdgeDetectionApp());
}

class EdgeDetectionApp extends StatelessWidget {
  const EdgeDetectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edge Detection Plugin Example',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _imagePath;
  int _selectedIndex = 0;
  bool _qrDetected = false;
  String _qrValue = '';
  Map<Object?, Object?>? _documentData;
  late EventChannel _eventChannel;
  late MethodChannel _methodChannel;

  @override
  void initState() {
    super.initState();
    print("starting 1");
    _checkPermissions();
    _setupEventChannel();
    _methodChannel = MethodChannel('scanner_view_0');
    print("starting 2");
  }

  // void _setupEventChannel() {
  //   _eventChannel = const EventChannel('scanner_events_0');
  //   _eventChannel.receiveBroadcastStream().listen((dynamic event) {
  //     print("Received event from native: $event");
  //     setState(() {
  //       _qrDetected = event['qrDetected'] ?? false;
  //       _qrValue = (event['qrValue'] as String?) ?? '';
  //       print("QR detected state: $_qrDetected");
  //       print("QR value: $_qrValue");
  //       if (_qrDetected) {
  //         ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('QR kód detekovaný: $_qrValue')));
  //       }
  //     });
  //   }, onError: (error) {
  //     print("Error from event channel: $error");
  //   });
  // }

  void _setupEventChannel() {
    _eventChannel = const EventChannel('scanner_events_0');
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      print("Main received event: $event");
      if (event is Map) {
        if (event['qrDetected'] != null) {
          setState(() {
            _qrDetected = event['qrDetected'] ?? false;
            _qrValue = (event['qrValue'] as String?) ?? '';
          });

          if (_qrDetected) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text('QR kód detekovaný: $_qrValue'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    }, onError: (error) {
      print("Main error: $error");
    });
  }

  void _onIndexChanged(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      // Ak sa prepneme späť na skener, reštartujeme kameru
      _methodChannel.invokeMethod('start_scan');
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      print("Camera permission denied");
    }
  }

  Future<void> _generateFilePath() async {
    final directory = await getApplicationSupportDirectory();
    setState(() {
      _imagePath = join(directory.path, "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
    });
    print("generated imagePath: $_imagePath");
  }

  Future<void> _captureImage() async {
    await _generateFilePath();
    print("Capturing image...");
    try {
      final result = await _methodChannel.invokeMethod('detectEdge', {
        'imagePath': _imagePath,
      });
      print("lipp Received result from native: $result");
      setState(() {
        _documentData = result;
        _selectedIndex = 1;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building with qrDetected: $_qrDetected");
    return Scaffold(
      appBar: AppBar(title: Text('Scanner')),
      body: _selectedIndex == 0
          ? Stack(
              children: [
                ScannerWidget(),
                // if (_qrDetected)
                Positioned(
                  bottom: 32,
                  right: 32,
                  child: FloatingActionButton.extended(
                    onPressed: _captureImage,
                    icon: Icon(Icons.camera),
                    label: Text('Zachytiť'),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            )
          : Column(children: [
              TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          GalleryScreen(imagePath: _imagePath!, documentData: _documentData.toString()))),
                  child: Text("Go to Gallery"))
            ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onIndexChanged,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Gallery'),
        ],
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final String imagePath;
  final String documentData;

  const GalleryScreen({Key? key, required this.imagePath, required this.documentData}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool showImage = false;

  @override
  Widget build(BuildContext context) {
    print("imimim imagePath: ${widget.imagePath}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showImage = !showImage;
              });
            },
            icon: Icon(Icons.image),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(children: [
          Text("Gallery"),
          Text(widget.documentData),
          // if (showImage)
          //   Image.file(
          //     File(widget.imagePath),
          //     key: ValueKey(widget.imagePath),
          //     cacheWidth: null,
          //     cacheHeight: null,
          //     gaplessPlayback: false,
          //   ),
          if (showImage)
            FutureBuilder(
              future: File(widget.imagePath).exists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    return Image.file(
                      File(widget.imagePath),
                      key: ValueKey(widget.imagePath),
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading image: $error");
                        return Text("Error loading image: $error");
                      },
                    );
                  } else {
                    return Text("File does not exist: ${widget.imagePath}");
                  }
                }
                return CircularProgressIndicator();
              },
            ),
        ]),
      ),
    );
  }
}
