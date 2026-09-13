import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final String currentLang;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    required this.currentLang,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(errorMessage,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(currentLang == 'uk' ? 'Спробувати знову' : 'Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A40),
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
