import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  final String currentLang;

  const LoadingStateWidget({super.key, required this.currentLang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: Colors.white38, strokeWidth: 1),
          const SizedBox(height: 16),
          Text(
            currentLang == 'uk' ? 'Завантаження...' : 'Loading...',
            style: const TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
