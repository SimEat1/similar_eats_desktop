import "package:flutter/material.dart";

class RatingSlider extends StatefulWidget {
  final String label;
  final int initialValue; // 1..5
  final ValueChanged<int> onChanged;
  final IconData? icon;

  const RatingSlider({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.icon,
  });

  @override
  State<RatingSlider> createState() => _RatingSliderState();
}

class _RatingSliderState extends State<RatingSlider> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text("${widget.label}: $_value/5"),
          ],
        ),
        Slider.adaptive(
          min: 1,
          max: 5,
          divisions: 4,
          label: _value.toString(),
          value: _value.toDouble(),
          onChanged: (v) => setState(() => _value = v.round()),
          onChangeEnd: (v) => widget.onChanged(v.round()),
        ),
      ],
    );
  }
}
