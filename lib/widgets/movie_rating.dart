import 'package:flutter/material.dart';

class MovieRating extends StatelessWidget {
  final double rating;
  final bool compact;

  const MovieRating({
    super.key,
    required this.rating,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(
          compact ? 10 : 12,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 13 : 15,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}