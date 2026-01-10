import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class InternetChecker extends StatefulWidget {
  final Widget child;
  const InternetChecker({super.key, required this.child});

  @override
  State<InternetChecker> createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker> {
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;
  bool _isConnected = true;

@override
void initState() {
  super.initState();
  _connectivity = Connectivity();
  _connectivityStream = _connectivity.onConnectivityChanged.map((list) => list.first);

  _connectivityStream.listen((ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;
    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;

      final message = hasConnection
          ? 'Internet connection restored.'
          : 'No internet connection.';

      final color = hasConnection ? Colors.green : Colors.red;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
