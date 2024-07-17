import 'package:flutter/material.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';

class FishButtonTabBarItem {
  FishButtonTabBarItem({this.title, this.icon, this.param});

  String? title;
  IconData? icon;
  dynamic param;
}

// ignore: must_be_immutable
class FishButtonTabBarWidget extends StatefulWidget {
  FishButtonTabBarWidget({super.key, required this.items, this.initIndex, this.onChanged});

  int? initIndex;
  final List<FishButtonTabBarItem> items;
  Function(int index, FishButtonTabBarItem item)? onChanged;

  @override
  State<FishButtonTabBarWidget> createState() => _FishButtonTabBarWidgetState();
}

class _FishButtonTabBarWidgetState extends State<FishButtonTabBarWidget> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {});
  }

  BorderSide _borderSide() {
    return const BorderSide();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.items.length, (i) {
        final item = widget.items[i];
        return FishInkwell(
          onTap: () {
            if (i != widget.initIndex) {
              if (widget.onChanged != null) {
                widget.onChanged!(i, item);
              }
            }
          },
          child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 6),
              decoration: BoxDecoration(
                  color: widget.initIndex == i ? UIConfig.selectedColor : Colors.transparent,
                  border: Border(
                    top: _borderSide(),
                    left: _borderSide(),
                    right: i == widget.items.length - 1 ? _borderSide() : BorderSide.none,
                    bottom: _borderSide(),
                  )),
              child: Row(
                children: [
                  if (item.icon != null)
                    Icon(item.icon, color: widget.initIndex == i ? Colors.white : Colors.black),
                  if (item.title != null)
                    Text(
                      item.title!,
                      style: TextStyle(color: widget.initIndex == i ? Colors.white : Colors.black),
                    )
                ],
              )),
        );
      }),
    );
  }
}
