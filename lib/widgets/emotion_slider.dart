import 'package:flutter/material.dart';

class EmotionSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const EmotionSlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  Color _getColor() {
    if (value < 25) return Colors.red;
    if (value < 50) return Colors.orange;
    if (value < 75) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getLabel() {
    if (value < 25) return '매우 나쁨';
    if (value < 50) return '나쁨';
    if (value < 75) return '좋음';
    return '매우 좋음';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('1', style: TextStyle(color: Colors.grey)),
            Column(
              children: [
                Text(
                  value.round().toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getColor(),
                  ),
                ),
                Text(
                  _getLabel(),
                  style: TextStyle(fontSize: 14, color: _getColor()),
                ),
              ],
            ),
            const Text('100', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getColor(),
            inactiveTrackColor: _getColor().withAlpha(51),
            thumbColor: _getColor(),
            overlayColor: _getColor().withAlpha(51),
            trackHeight: 8,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
