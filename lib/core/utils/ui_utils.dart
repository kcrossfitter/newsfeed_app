import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent, // 예시 스타일
    ),
  );
}

// void showSuccessSnackbar(BuildContext context, {required String message}) { ... }

// Future<void> showAlertDialog(BuildContext context, {required String title, required String content}) { ... }
