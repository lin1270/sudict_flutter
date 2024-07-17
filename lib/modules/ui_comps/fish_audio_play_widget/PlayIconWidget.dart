// ignore_for_file: file_names

import 'package:flutter/material.dart';

class PlayIconController extends ChangeNotifier {
  int actionMode = -1;

  play() {
    actionMode = 1;
    notifyListeners();
  }

  stop() {
    actionMode = 2;
    notifyListeners();
  }
}

// ignore: must_be_immutable
class PlayIconWidget extends StatefulWidget {
  PlayIconWidget({super.key, this.controller});

  PlayIconController? controller;

  @override
  State<StatefulWidget> createState() => PlayIconWidgetState();
}

class PlayIconWidgetState extends State<PlayIconWidget> with TickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 10), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller!);

    widget.controller?.addListener(() {
      if (widget.controller!.actionMode == 1) {
        controller!.repeat();
      } else if (widget.controller!.actionMode == 2) {
        controller!.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipOval(
      child: RotationTransition(
          turns: animation!,
          child: Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white54),
            child: Icon(
              Icons.music_note,
              color: Colors.black,
              size: size.width / 2,
            ),
          )),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
