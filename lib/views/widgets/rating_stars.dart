import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final double size;
  final Function(int)? onRate;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 28,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final filled = index < rating;

        return IconButton(
          iconSize: size,
          padding: EdgeInsets.zero,
          onPressed: onRate != null ? () => onRate!(index + 1) : null,
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
