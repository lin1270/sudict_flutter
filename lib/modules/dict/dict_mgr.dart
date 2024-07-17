import 'package:sudict/config/dict.dart';
import 'package:sudict/modules/dict/dict_group.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/local_storage.dart';

class DictMgr {
  DictMgr._(this.isMainInstance);
  static DictMgr? _instance;
  static DictMgr get instance {
    _instance ??= DictMgr._(true);
    return _instance!;
  }

  static DictMgr? _tempInstance;
  static DictMgr get tempInstance {
    _tempInstance ??= DictMgr.instance._copy();
    _tempInstance!.isMainInstance = false;

    return _tempInstance!;
  }

  final List<DictGroup> _dictGroupsForSetting = [];
  List<DictGroup> get allGroupForSetting => _dictGroupsForSetting;
  bool isMainInstance;

  final List<DictGroup> _dictGroups = [];
  int _currentGroupIndex = 0;
  Map<int, int> _currDictIndex = {};

  DictMgr _copy() {
    final obj = DictMgr._(isMainInstance);
    obj._dictGroupsForSetting.addAll(_dictGroupsForSetting);
    obj._dictGroups.addAll(_dictGroups);
    obj._currentGroupIndex = _currentGroupIndex;
    obj._currDictIndex.addAll(_currDictIndex);
    return obj;
  }

  List<DictGroup> get allGroup => _dictGroups;
  int get groupCount => _dictGroups.length;
  int get currentGroupIndex => _currentGroupIndex;
  DictGroup get currentGroup => _dictGroups[currentGroupIndex];
  DictGroup getGroupByIndex(int index) => _dictGroups[index];
  DictItem get currItem => currentGroup.items[_currDictIndex[currentGroupIndex] ?? 0];
  DictItem getDictItemInCurrentGroupByIndex(int index) => currentGroup.items[index];
  DictItem getDictItem(int groupIndex, int itemIndex) => _dictGroups[groupIndex].items[itemIndex];
  DictItem getCurrentDictItemInGroup(DictGroup group) {
    int index = _dictGroups.indexOf(group);
    return group.items[_currDictIndex[index]!];
  }

  int getGroupIndex(DictGroup item) => _dictGroups.indexOf(item);

  init() async {
    _dictGroupsForSetting.clear();
    _dictGroups.clear();
    _currDictIndex = {};

    // read cfg
    _currentGroupIndex =
        await LocalStorageUtils.getInt(LocalStorageKeys.currentDictGroupIndex) ?? 0;
    for (int i = 0; i < DictConfig.maxGroupCount; ++i) {
      _currDictIndex[i] =
          await LocalStorageUtils.getInt('${LocalStorageKeys.currentDictPre}_$i') ?? 0;
    }

    final json = await AssetsUtils.readJsonFile('assets/dict/index.json');
    if (json == null) return;
    final assetsDictGroups = <DictGroup>[];
    for (dynamic jsonItem in json) {
      assetsDictGroups.add(DictGroup.fromJson(jsonItem));
    }

    // load dict cfg
    dynamic dictsSetting = await LocalStorageUtils.getJson(LocalStorageKeys.dictsSetting);
    final settingDictGroups = _dictGroupsForSetting;
    if (dictsSetting != null) {
      for (dynamic jsonItem in dictsSetting) {
        settingDictGroups.add(DictGroup.fromJson(jsonItem));
      }
    }

    if (settingDictGroups.isNotEmpty) {
      for (DictGroup settingGroup in settingDictGroups) {
        // must exist
        int index = assetsDictGroups.indexWhere((element) => element.id == settingGroup.id);
        if (index >= 0) {
          final assetsGroup = assetsDictGroups[index];
          for (DictItem dict in assetsGroup.items) {
            // if not found, add
            // need search all group, because user may remove to other group
            final foundDict = getDictById(dict.id);
            if (foundDict == null) {
              settingGroup.items.add(dict);
            }
          }

          // if updated,  assets removed, setting remove
          for (int i = settingGroup.items.length - 1; i >= 0; --i) {
            final dict = settingGroup.items[i];
            if (dict.from == DictFrom.res) {
              if (assetsGroup.items.indexWhere((element) => element.id == dict.id) < 0) {
                settingGroup.items.removeAt(i);
              }
            }
          }
        }
      }
    }

    // insert not exist
    int assetsIndex = 0;
    for (DictGroup ai in assetsDictGroups) {
      final id = ai.id;
      int index = settingDictGroups.indexWhere((element) => element.id == id);
      if (index == -1) {
        settingDictGroups.add(assetsDictGroups[assetsIndex]);
      }
      ++assetsIndex;
    }

    refreshShownDicts();

    if (_currentGroupIndex >= allGroupForSetting.length) _currentGroupIndex = 0;
  }

  DictItem? getDictById(String id) {
    for (DictGroup group in allGroupForSetting) {
      int index = group.items.indexWhere((element) => element.id == id);
      if (index >= 0) return group.items[index];
    }
    return null;
  }

  refreshShownDicts() {
    _dictGroups.clear();
    int groupIndex = 0;
    for (DictGroup group in _dictGroupsForSetting) {
      DictGroup shown = DictGroup(group.id, group.name, group.from, []);
      for (final dict in group.items) {
        if (dict.visible) {
          shown.items.add(dict);
        }
      }

      _dictGroups.add(shown);

      var index = getCurrentDictItemIndexInGroup(group: shown);
      if (index < 0 || index >= shown.items.length) {
        index = 0;
        _currDictIndex[groupIndex] = index;
        _saveCurrentDictIndex(groupIndex, index);
      }
      ++groupIndex;
    }
  }

  setDictVisible(DictItem dict, bool visible) {
    dict.visible = visible;
    refreshShownDicts();
    saveCfg();
  }

  saveCfg() {
    if (!isMainInstance) return;
    // 主DICT有修改时，清掉TEMP
    _tempInstance = null;

    var json = [];
    for (DictGroup group in _dictGroupsForSetting) {
      json.add(group.toJson());
    }
    LocalStorageUtils.setJson(LocalStorageKeys.dictsSetting, json);
  }

  changeDictPos({required DictGroup group, required int from, required int to}) {
    DictItem item = group.items.removeAt(from);
    if (to > from) --to;

    group.items.insert(to, item);

    if (item.visible) refreshShownDicts();
    saveCfg();
  }

  int getCurrentDictItemIndexInGroup({DictGroup? group, int? index}) {
    if (group != null) {
      index = _dictGroups.indexWhere(
        (element) {
          return element.id == group.id;
        },
      );
    }
    return _currDictIndex[index]!;
  }

  _saveCurrDictGroupIndex(int index) async {
    if (!isMainInstance) return;
    // 主DICT有修改时，清掉TEMP
    _tempInstance = null;
    return await LocalStorageUtils.setInt(
        LocalStorageKeys.currentDictGroupIndex, _currentGroupIndex);
  }

  goNextGroup() {
    _currentGroupIndex = (_currentGroupIndex + 1) % groupCount;
    _saveCurrDictGroupIndex(_currentGroupIndex);
  }

  _saveCurrentDictIndex(int groupIndex, int index) async {
    if (!isMainInstance) return;
    // 主DICT有修改时，清掉TEMP
    _tempInstance = null;
    return await LocalStorageUtils.setInt('${LocalStorageKeys.currentDictPre}_$groupIndex', index);
  }

  setCurrentIndex({required int groupIndex, required int index}) {
    _currDictIndex[groupIndex] = index;
    _saveCurrentDictIndex(groupIndex, index);
  }

  setCurrentGroupCurrDictIndex({int? index, DictItem? dict}) {
    if (index != null) {
      if (index >= 0 && index < currentGroup.items.length) {
        _currDictIndex[currentGroupIndex] = index;
        _saveCurrentDictIndex(currentGroupIndex, index);
      }
    } else if (dict != null) {
      int foundIndex = currentGroup.items.indexOf(dict);
      if (foundIndex >= 0) {
        setCurrentGroupCurrDictIndex(index: foundIndex);
      }
    }
  }

  deleteDict(DictItem item) {
    for (DictGroup group in _dictGroupsForSetting) {
      if (group.items.remove(item)) {
        refreshShownDicts();
        saveCfg();
        break;
      }
    }
  }

  void addDict(int groupIndex, DictItem item) {
    var group = _dictGroupsForSetting[groupIndex];
    group.items.add(item);
    if (item.visible) {
      refreshShownDicts();
    }

    saveCfg();
  }

  List<DictItem> getDictByPath(String path,
      {from = DictFrom.user, justFileName = false, groupIndex = -1}) {
    final ret = <DictItem>[];
    if (groupIndex == -1) {
      for (DictGroup group in _dictGroupsForSetting) {
        for (DictItem item in group.items) {
          if (item.from == from) {
            if (justFileName) {
              if (item.path.endsWith('/$path')) {
                ret.add(item);
              }
            } else if (item.path == path) {
              ret.add(item);
            }
          }
        }
      }
    } else {
      if (groupIndex >= 0 && groupIndex < _dictGroupsForSetting.length) {
        final group = _dictGroupsForSetting[groupIndex];
        for (DictItem item in group.items) {
          if (item.from == from) {
            if (justFileName) {
              if (item.path.endsWith('/$path')) {
                ret.add(item);
              }
            } else if (item.path == path) {
              ret.add(item);
            }
          }
        }
      }
    }

    return ret;
  }

  int deleteUserGroup(DictGroup item) {
    if (item.from != DictFrom.user) return -1;
    final index = allGroupForSetting.indexOf(item);
    if (index >= 0) {
      allGroupForSetting.removeAt(index);
      refreshShownDicts();
      if (_currentGroupIndex >= allGroupForSetting.length) _currentGroupIndex = 0;

      DictMgr.instance.saveCfg();
      return index;
    }
    return -1;
  }

  Future<void> restore() async {
    if (!isMainInstance) return;
    // 主DICT有修改时，清掉TEMP
    _tempInstance = null;

    await _saveCurrDictGroupIndex(0);
    for (int i = 0; i < DictConfig.maxGroupCount; ++i) {
      await LocalStorageUtils.setInt('${LocalStorageKeys.currentDictPre}_$i', 0);
    }
    await LocalStorageUtils.setJson(LocalStorageKeys.dictsSetting, []);
    await init();
  }
}
