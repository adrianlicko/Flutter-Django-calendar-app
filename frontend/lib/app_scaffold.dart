import 'package:flutter/material.dart';
import 'package:frontend/services/connectivity_service.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBarActions;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.showAppBarActions = true,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _isCheckingConnection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ConnectivityService>(context, listen: false).checkConnectivityToBackend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(builder: (context, connectivityService, child) {
      final bool hasConnectionToBackend = connectivityService.hasConnectionToBackend;

      List<Widget> actions = !widget.showAppBarActions
          ? []
          : [
              if (_isCheckingConnection)
                const SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    color: Colors.red,
                  ),
                ),
              if (!hasConnectionToBackend)
                IconButton(
                  onPressed: () async {
                    if (_isCheckingConnection) return;
                    setState(() {
                      _isCheckingConnection = true;
                    });
                    await connectivityService.checkConnectivityToBackend(context: context);
                    setState(() {
                      _isCheckingConnection = false;
                    });
                  },
                  icon: Icon(
                    Icons.signal_cellular_connected_no_internet_0_bar_outlined,
                    color: _isCheckingConnection ? Colors.grey : Colors.red,
                  ),
                ),
              if (widget.actions != null) ...widget.actions!,
            ];

      return Scaffold(
        floatingActionButton: widget.floatingActionButton,
        appBar: AppBar(
          leading: widget.leading != null ? Row(children: widget.leading!) : null,
          title: widget.title != null ? Text(widget.title!) : null,
          actions: actions,
        ),
        body: widget.body,
      );
    });
  }
}
