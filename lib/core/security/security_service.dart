import 'dart:async';
import 'package:flutter/material.dart';

class SecurityService with WidgetsBindingObserver {
  final Duration inactivityTimeout;
  final VoidCallback onInactivityTimeout;
  final Function(bool isBackgrounded)? onAppLifecycleChanged;

  Timer? _inactivityTimer;

  SecurityService({
    this.inactivityTimeout = const Duration(minutes: 15),
    required this.onInactivityTimeout,
    this.onAppLifecycleChanged,
  }) {
    WidgetsBinding.instance.addObserver(this);
    resetInactivityTimer();
  }

  void resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, () {
      onInactivityTimeout();
    });
  }

  void onUserInteraction() {
    resetInactivityTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      onAppLifecycleChanged?.call(true);
    } else if (state == AppLifecycleState.resumed) {
      onAppLifecycleChanged?.call(false);
      resetInactivityTimer();
    }
  }

  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
