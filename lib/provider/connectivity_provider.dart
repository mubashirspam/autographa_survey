import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  static final ConnectivityProvider _instance = ConnectivityProvider._internal();
  factory ConnectivityProvider() => _instance;
  ConnectivityProvider._internal();
  
  bool _isConnected = true;
  final Connectivity _connectivity = Connectivity();
  Timer? _verificationTimer;
  bool _isVerifying = false;


  
  // Stream controller for connectivity status
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectionStatusController.stream;



  bool get isConnected => _isConnected;
  
 
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _verifyInternetConnection(results);
      
      // Set up listener after initial check
      _connectivity.onConnectivityChanged.listen((results) async {
        await _verifyInternetConnection(results);
      });
    } catch (e) {
      _updateConnectionStatus(false);
    }
  }

  Future<bool> _checkRealConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  
  Future<void> _verifyInternetConnection(List<ConnectivityResult> results) async {
    if (_isVerifying) return;
    _isVerifying = true;
    
    final hasConnectivity = !results.contains(ConnectivityResult.none) || results.length > 1;
    final hasRealConnection = hasConnectivity ? await _checkRealConnection() : false;
    final isNowConnected = hasConnectivity && hasRealConnection;
    
    if (_isConnected != isNowConnected) {
      _updateConnectionStatus(isNowConnected);
    }
    
    _isVerifying = false;
    
    // Schedule periodic check if not connected
    if (!isNowConnected) {
      _startPeriodicCheck();
    } else {
      _stopPeriodicCheck();
    }
  }
  
  void _startPeriodicCheck() {
    _stopPeriodicCheck();
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final results = await _connectivity.checkConnectivity();
      await _verifyInternetConnection(results);
    });
  }
  
  void _stopPeriodicCheck() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
  }

  void _updateConnectionStatus(bool isConnected) {

    _isConnected = isConnected;
    
    // Notify listeners and update stream
    notifyListeners();
    _connectionStatusController.add(isConnected);
    
    debugPrint('Connectivity status changed to: ${isConnected ? 'Online' : 'Offline'}');
    

  }
  
 

  // Method to manually check connectivity
  Future<void> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    await _verifyInternetConnection(results);
  }
  
  @override
  void dispose() {
    _verificationTimer?.cancel();
    _connectionStatusController.close();
    super.dispose();
  }
}
