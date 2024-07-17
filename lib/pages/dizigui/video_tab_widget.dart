import 'package:flutter/material.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/ui_comps/fish_video_list_play_widget/index.dart';

class DiziguiVideoTabWidget extends StatelessWidget {
  const DiziguiVideoTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: FishVideoPlayWidget(
        catalog: AudioVideoPlayCatalog.dizigui,
        baseUrl: 'http://www.maiyuren.com/static/more/dizigui/video',
        count: 41,
        aspectRatio: 640 / 480.0,
      ),
    );
  }
}
