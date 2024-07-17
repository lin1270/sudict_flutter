class DictWord {
  DictWord(
      {this.index = 0,
      this.word = "",
      this.content,
      this.group = "",
      this.offset = -1,
      this.length = 0});

  DictWord.copy(DictWord fromObj) {
    index = fromObj.index;
    word = fromObj.word;
    content = fromObj.content;
    group = fromObj.group;
    offset = fromObj.offset;
    length = fromObj.length;
  }

  int index = 0;
  String word = "";
  String? content;
  String group = "";
  int offset = -1;
  int length = 0;
}
