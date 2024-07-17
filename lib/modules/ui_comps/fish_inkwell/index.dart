import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FishInkwell extends StatelessWidget {
  FishInkwell(
      {super.key, this.onTap, this.onDoubleTap, this.onLongPress, this.hoverColor, this.child});

  void Function()? onTap;
  void Function()? onDoubleTap;
  void Function()? onLongPress;
  Widget? child;
  Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        hoverColor: hoverColor,
        child: child,
      ),
    );
  }
}
