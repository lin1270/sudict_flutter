class FishEventBus {
  FishEventBus._();
  static final _cbs = <String, List<Function>>{};

  static onEvent<T>(Function(T) cb) {
    final key = T.toString();
    var items = _cbs[key];
    if (items == null) {
      items = <Function>[];
      _cbs[key] = items;
    }
    items.add(cb);
  }

  static offEvent<T>(Function(T) cb) {
    final key = T.toString();
    var items = _cbs[key];
    if (items != null) {
      items.remove(cb);
    }
  }

  static fire<T>(T data) {
    final key = T.toString();
    var items = _cbs[key];
    if (items != null) {
      for (final cb in items) {
        cb(data);
      }
    }
  }
}
