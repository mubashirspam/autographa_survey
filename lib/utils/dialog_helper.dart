import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DialogHelper {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  static Future<void> showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? positiveButtonText,
    String? negativeButtonText,
    VoidCallback? onPositivePressed,
    VoidCallback? onNegativePressed,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (negativeButtonText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNegativePressed?.call();
                },
                child: Text(negativeButtonText),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPositivePressed?.call();
              },
              child: Text(positiveButtonText ?? 'OK'),
            ),
          ],
        );
      },
    );
  }
}
