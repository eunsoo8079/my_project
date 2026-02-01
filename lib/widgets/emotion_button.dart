import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmotionButton extends StatefulWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const EmotionButton({
    super.key,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<EmotionButton> createState() => _EmotionButtonState();
}

class _EmotionButtonState extends State<EmotionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emotionColor =
        AppColors.emotionColors[widget.emoji] ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? emotionColor.withAlpha(40)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? emotionColor
                      : Colors.grey.withAlpha(50),
                  width: widget.isSelected ? 3 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: emotionColor.withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: widget.isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
