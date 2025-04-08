import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/connectivity_provider.dart';

/// A widget that displays the current connectivity status as a chip
class ConnectivityStatus extends StatelessWidget {
  const ConnectivityStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        final isConnected = provider.isConnected;
        
        return Chip(
          label: Text(
            isConnected ? 'Online' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}
