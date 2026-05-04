import 'package:flutter/material.dart';

class NavigationUtils {
  static void dismissCurrentSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void navigateAndClearStack(BuildContext context, Widget destination) {
    // Dismiss any active alerts/snackbars before navigation
    dismissCurrentSnackBar(context);
    
    // Navigate and clear the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  static void navigateWithContext(BuildContext context, Widget destination) {
    // Dismiss any active alerts/snackbars before navigation
    dismissCurrentSnackBar(context);
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }
}
