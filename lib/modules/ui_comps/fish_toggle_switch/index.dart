import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FishToggleSwitchWidget extends StatefulWidget {
  FishToggleSwitchWidget(
      {super.key,
      required this.isOn,
      this.onChanged,
      this.onText,
      this.offText,
      this.offBackgroundColor = Colors.black38});

  final bool isOn;
  final ChangeCallback<bool>? onChanged;
  final String? onText;
  final String? offText;
  Color offBackgroundColor;

  @override
  State<FishToggleSwitchWidget> createState() => _FishToggleSwitchWidgetState();
}

class _FishToggleSwitchWidgetState extends State<FishToggleSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedToggleSwitch<bool>.dual(
        current: widget.isOn,
        first: false,
        second: true,
        spacing: 30.0,
        indicatorSize: const Size.fromWidth(26),
        animationDuration: const Duration(milliseconds: 200),
        style: const ToggleStyle(
          borderColor: Colors.transparent,
          indicatorColor: Colors.white,
          backgroundColor: Colors.amber,
        ),
        customStyleBuilder: (context, local, global) => ToggleStyle(
                backgroundGradient: LinearGradient(
              colors: [Colors.green, widget.offBackgroundColor],
              stops: [
                global.position - (1 - 2 * max(0, global.position - 0.5)) * 0.5,
                global.position + max(0, 2 * (global.position - 0.5)) * 0.5,
              ],
            )),
        borderWidth: 2.0,
        height: 30.0,
        loadingIconBuilder: (context, global) => CupertinoActivityIndicator(
            color: Color.lerp(Colors.black38, Colors.green, global.position)),
        onChanged: widget.onChanged,
        textBuilder: (widget.onText?.isNotEmpty == true || widget.offText?.isNotEmpty == true)
            ? (value) => Center(
                    child: Text(
                  (value ? widget.onText : widget.offText) ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 11.0),
                ))
            : null);
  }
}
