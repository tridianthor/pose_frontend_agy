import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PosSearchIntent extends Intent {
  const PosSearchIntent();
}

class PosCartIntent extends Intent {
  const PosCartIntent();
}

class PosCheckoutIntent extends Intent {
  const PosCheckoutIntent();
}

class PosKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSearchShortcut;
  final VoidCallback? onCartShortcut;
  final VoidCallback? onCheckoutShortcut;

  const PosKeyboardShortcuts({
    super.key,
    required this.child,
    this.onSearchShortcut,
    this.onCartShortcut,
    this.onCheckoutShortcut,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.f1): const PosSearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.f2): const PosCartIntent(),
        LogicalKeySet(LogicalKeyboardKey.f12): const PosCheckoutIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PosSearchIntent: CallbackAction<PosSearchIntent>(
            onInvoke: (intent) {
              onSearchShortcut?.call();
              return null;
            },
          ),
          PosCartIntent: CallbackAction<PosCartIntent>(
            onInvoke: (intent) {
              onCartShortcut?.call();
              return null;
            },
          ),
          PosCheckoutIntent: CallbackAction<PosCheckoutIntent>(
            onInvoke: (intent) {
              onCheckoutShortcut?.call();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
