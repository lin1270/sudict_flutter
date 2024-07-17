import 'package:flutter/material.dart';

enum AudioVideoPlayCatalog { xiguicidi, dizigui }

enum AudioVideoPlayStatus {
  notPlay,
  failed,
  playing,
  paused,
  completed,
}

enum AudioVideoPlayMode {
  seq(Icons.repeat),
  random(Icons.shuffle),
  one(Icons.repeat_one);

  const AudioVideoPlayMode(this.icon);
  final IconData icon;
}
