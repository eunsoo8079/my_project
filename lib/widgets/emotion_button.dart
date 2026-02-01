import 'package:flutter/material.dart';

class EmotionButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const EmotionButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
      ),
    );
  }
}
