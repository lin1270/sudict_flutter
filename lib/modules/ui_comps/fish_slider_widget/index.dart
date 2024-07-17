import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/fish_slider_widget/wdCustomTrackShape.dart';

class FishSliderWidget extends StatelessWidget {
  const FishSliderWidget(
      {super.key, this.onChanged, required this.value, this.min = 00, this.max = 100.0});

  final ValueChanged<double>? onChanged;
  final double value;
  final double max;
  final double min;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 8,
        inactiveTrackColor: Colors.black12,
        activeTrackColor: Colors.blue,
        disabledActiveTrackColor: Colors.blue,
        disabledInactiveTrackColor: Colors.blue,
        thumbColor: Colors.white,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
        trackShape: WDCustomTrackShape(addHeight: 0),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}
