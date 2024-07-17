import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/dict_group_native_widget.dart';

// ignore: must_be_immutable
class DictGroupMenuWidget extends StatefulWidget {
  DictGroupMenuWidget({super.key, required this.groupIndex, this.groupController});

  int groupIndex;
  DictGroupNativeWidgetController? groupController;

  @override
  State<DictGroupMenuWidget> createState() => _DictGroupMenuWidgetState();
}

class _DictGroupMenuWidgetState extends State<DictGroupMenuWidget> {
  @override
  void dispose() {
    FishEventBus.offEvent<DictSettingChangedEvent>(_onDictSettingChangedEvent);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    FishEventBus.onEvent<DictSettingChangedEvent>(_onDictSettingChangedEvent);
  }

  _onDictSettingChangedEvent(DictSettingChangedEvent event) {
    if (event.groupIndex == widget.groupIndex) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = DictMgr.instance.getGroupByIndex(widget.groupIndex);
    return DropdownButtonHideUnderline(
        child: DropdownButton2(
      customButton: Container(),
      isExpanded: true,
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
      ),
      dropdownStyleData: const DropdownStyleData(
        width: 200,
      ),
      onChanged: (v) {},
      items: group.items.map((item) {
        return DropdownMenuItem(
            value: item,
            onTap: () {
              widget.groupController?.changeDict(item);
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      }).toList(),
    ));
  }
}
