import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? text;

  const LoadingIndicator({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.redAccent),
          if (text != null) ...[
            const SizedBox(height: 16),
            Text(
              text!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ]
        ],
      ),
    );
  }
}
