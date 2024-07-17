import 'package:sudict/modules/audio/common.dart';

class DictSettingChangedEvent {
  DictSettingChangedEvent(this.groupIndex);
  int groupIndex;
}

class DictSettingGroupAddOrRemoveEvent {
  DictSettingGroupAddOrRemoveEvent(this.groupIndex);
  int groupIndex;
}

class ShowRandomWidgetEvent {}

class SearchWordEvent {
  SearchWordEvent(this.word);
  String word;
}

class ClearFavoriteEvent {}

class UpdateFavorite {
  UpdateFavorite(this.word);
  String word;
}

class UpdateAudioCatalog {
  AudioVideoPlayCatalog catalog;
  bool play;

  UpdateAudioCatalog(this.catalog, this.play);
}
