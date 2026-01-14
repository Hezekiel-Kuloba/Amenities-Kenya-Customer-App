import 'package:flutter/material.dart';

class CustomDialogs {
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 20)),
          ],
        ),
        content: Text(content, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 20)),
          ],
        ),
        content: Text(content, style: const TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 20)),
          ],
        ),
        content: Text(content, style: const TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onPressed?.call();
            },
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}