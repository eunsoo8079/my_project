import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmotionSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const EmotionSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Color _getColor() {
    if (value < 25) return const Color(0xFF4CAF50); // 초록 - 약함
    if (value < 50) return const Color(0xFFFFC107); // 노랑 - 보통
    if (value < 75) return const Color(0xFFFF9800); // 주황 - 강함
    return const Color(0xFFE53935); // 빨강 - 매우 강함
  }

  String _getLabel() {
    if (value < 25) return '약함';
    if (value < 50) return '보통';
    if (value < 75) return '강함';
    return '매우 강함';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLabel(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${value.round()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withAlpha(40),
              thumbColor: Colors.white,
              overlayColor: color.withAlpha(30),
              trackHeight: 10,
              thumbShape: _CustomThumbShape(color: color),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(value: value, min: 1, max: 100, onChanged: onChanged),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '100',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Color color;

  const _CustomThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // 그림자
    final shadowPaint = Paint()
      ..color = color.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center + const Offset(0, 2), 14, shadowPaint);

    // 흰색 배경
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 14, bgPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 12, borderPaint);

    // 내부 원
    final innerPaint = Paint()..color = color;
    canvas.drawCircle(center, 6, innerPaint);
  }
}
