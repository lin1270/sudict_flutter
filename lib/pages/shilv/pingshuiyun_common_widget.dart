import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/shilv/pingshuiyun_data_mgr.dart';

Widget resultWidget(List<PingshuiyunCatalog> searchResult, String searchWord) {
  final currTabIndex = ValueNotifier<int>(0);
  return Column(
    children: [
      Row(
        children: [
          const Text(
            '搜尋結果：',
            style: TextStyle(color: Colors.black54),
          ),
          if (searchResult.isEmpty) const Text('未搜尋到結果'),
          Expanded(
            child: SizedBox(
                height: 32,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: searchResult.length,
                    itemBuilder: (context, i) {
                      return Container(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        alignment: Alignment.center,
                        child: FishInkwell(
                            onTap: () {
                              currTabIndex.value = i;
                            },
                            child: ValueListenableBuilder(
                                valueListenable: currTabIndex,
                                builder: (context, v, widget) {
                                  return Text(
                                    searchResult[i].fullName,
                                    style: TextStyle(
                                        color: v == i ? Colors.black : Colors.black45,
                                        fontWeight: v == i ? FontWeight.bold : FontWeight.normal),
                                  );
                                })),
                      );
                    })),
          ),
        ],
      ),
      if (searchResult.isNotEmpty)
        ValueListenableBuilder(
            valueListenable: currTabIndex,
            builder: (context, v, widget) {
              return Expanded(child: catalogWidget(searchResult[v], searchWord));
            })
    ],
  );
}

Widget catalogWidget(PingshuiyunCatalog catalog, String currWord) {
  return SingleChildScrollView(
      child: Wrap(
          children: List.generate(catalog.items.length, (wordIndex) {
    final word = catalog.items[wordIndex];
    return FishInkwell(
      onTap: () {
        UiUtils.showTempDictDialog(NavigatorUtils.currContext!, word);
      },
      child: Container(
        width: 44,
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        color: word == currWord ? Colors.red.shade300 : Colors.transparent,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              word,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${wordIndex + 1}',
              style: const TextStyle(fontSize: 9, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  })));
}

Widget groupWidget(Function(PingshuiyunCatalog catalog)? callback) {
  return FlutterListView.builder(
      itemCount: PingshuiyunDataMgr.instance.data.length,
      itemBuilder: (context, index) {
        final group = PingshuiyunDataMgr.instance.data[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0)
              const SizedBox(
                height: 8,
              ),
            Text(
              '  ${group.name}',
              style: const TextStyle(color: Colors.purple, fontSize: 11),
            ),
            Wrap(
                children: List.generate(group.items.length, (gi) {
              final catalog = group.items[gi];
              return FishInkwell(
                onTap: () {
                  if (callback != null) {
                    callback(catalog);
                  }
                },
                child: Container(
                  width: 36,
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        catalog.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        '${gi + 1}',
                        style: const TextStyle(fontSize: 9, color: Colors.black54),
                      )
                    ],
                  ),
                ),
              );
            }))
          ],
        );
      });
}
