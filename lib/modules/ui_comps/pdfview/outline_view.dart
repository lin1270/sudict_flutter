//
// Just a rough implementation of the document index
//
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';

class OutlineView extends StatelessWidget {
  const OutlineView({
    super.key,
    required this.outline,
    required this.controller,
  });

  final List<PdfOutlineNode>? outline;
  final PdfViewerController controller;

  @override
  Widget build(BuildContext context) {
    final treeController = TreeController<PdfOutlineNode>(
      roots: outline ?? [],
      childrenProvider: (PdfOutlineNode node) => node.children,
    );

    return Padding(
        padding: const EdgeInsets.all(8),
        child: outline?.isEmpty == true
            ? const Text('暫無目錄')
            : AnimatedTreeView<PdfOutlineNode>(
                treeController: treeController,
                nodeBuilder: (BuildContext context, TreeEntry<PdfOutlineNode> entry) {
                  return FishInkwell(
                    onTap: () {
                      treeController.toggleExpansion(entry.node);
                      controller.goToDest(entry.node.dest);
                    },
                    child: TreeIndentation(
                        entry: entry,
                        guide: const IndentGuide(indent: 20),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Row(
                            children: [
                              entry.hasChildren
                                  ? Icon(
                                      entry.isExpanded
                                          ? Icons.folder_open_outlined
                                          : Icons.folder_outlined,
                                      size: 20,
                                    )
                                  : const Icon(
                                      Icons.description_outlined,
                                      size: 20,
                                    ),
                              Expanded(
                                  child: Text(
                                entry.node.title,
                                style: const TextStyle(overflow: TextOverflow.ellipsis),
                              ))
                            ],
                          ),
                        )),
                  );
                },
              ));
  }
}
