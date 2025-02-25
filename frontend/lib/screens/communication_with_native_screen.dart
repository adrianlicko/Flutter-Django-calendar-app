import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app_scaffold.dart';

class CommunicationWithNativeScreen extends StatefulWidget {
  const CommunicationWithNativeScreen({super.key});

  @override
  State<CommunicationWithNativeScreen> createState() => _CommunicationWithNativeScreenState();
}

class _CommunicationWithNativeScreenState extends State<CommunicationWithNativeScreen> {
  final channel = const MethodChannel('channel_name');
  late String resultText = '';
  TextEditingController textController = TextEditingController();

  Future<void> _callNativeCode(String userName) async {
    try {
      resultText = await channel.invokeMethod('method_name', {'username': userName});
      setState(() {});
    } catch (_) {}
  }

  Future<void> _startScanning() async {
    try {
      resultText = await channel.invokeMethod('method_scan');
      setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Column(
      children: [
        TextButton(
            onPressed: () {
              String userName = textController.text;
              if (userName.isEmpty) {
                userName = "StudentApp";
              }
              _callNativeCode(userName);
            },
            child: const Text("Show toast")),
        const SizedBox(height: 24),
        TextField(controller: textController),
        TextButton(onPressed: () {
          _startScanning();
        }, child: Text("Start scanning"))
      ],
    ));
  }
}
