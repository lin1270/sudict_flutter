class DictRedirectResult {
  DictRedirectResult(this.template, this.from, this.to);

  String template;
  String from;
  String to;
}

class DictRedirect {
  DictRedirect({required this.content}) {
    int begin = 0;
    while (begin < content.length) {
      final keyPos = content.indexOf('\t', begin);
      if (keyPos == -1) break;
      final key = content.substring(begin, keyPos);
      var valuePos = content.indexOf('\n', keyPos + 1);
      if (valuePos == -1) valuePos = content.length;
      final value = content.substring(keyPos + 1, valuePos);
      begin = valuePos + 1;

      if (key == "__TEMPLATE__") {
        template = value;
      } else {
        kvs[key] = value.endsWith('\r') ? value.substring(0, value.length - 1) : value;
      }
    }
  }

  String template = "";
  var kvs = <String, String>{};
  String content;

  DictRedirectResult? search(String word) {
    for (var key in kvs.keys) {
      if (word == key) {
        var value = kvs[key]!;
        return DictRedirectResult(
            template.replaceAll("\${1}", key).replaceAll("\${2}", value), key, value);
      }
    }

    for (var key in kvs.keys) {
      if (word.startsWith(key)) {
        var value = kvs[key]!;
        return DictRedirectResult(
            template.replaceAll("\${1}", key).replaceAll("\${2}", value), key, value);
      }
    }

    for (var key in kvs.keys) {
      if (key.startsWith(word)) {
        var value = kvs[key]!;
        return DictRedirectResult(
            template.replaceAll("\${1}", key).replaceAll("\${2}", value), key, value);
      }
    }
    return null;
  }
}
