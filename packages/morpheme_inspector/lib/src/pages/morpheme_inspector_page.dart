import 'package:flutter/material.dart';
import 'package:morpheme_inspector/src/extensions/inspector_extensions.dart';
import 'package:morpheme_inspector/src/pages/morpheme_inspector_detail_page.dart';
import 'package:morpheme_inspector/src/widgets/item_inspector.dart';
import 'package:morpheme_inspector/src/widgets/theme_inspector.dart';

import '../models/inspector.dart';
import '../service/inspector_service.dart';

/// The page will display list morpheme inspector http.
class MorphemeInspectorPage extends StatefulWidget {
  const MorphemeInspectorPage({super.key});

  @override
  State<MorphemeInspectorPage> createState() => _MorphemeInspectorPageState();
}

class _MorphemeInspectorPageState extends State<MorphemeInspectorPage> {
  /// The master data list of [Inspector]
  List<Inspector> masterListInspector = [];

  /// The list of [Inspector] will used to show list data inspector.
  List<Inspector> listInspector = [];

  /// Flag used to toggle search mode.
  bool isSearchMode = false;

  /// Emit list of [Inspector] get all data from local data
  void getAllInspector() async {
    final list = await InspectorService.getAll();
    masterListInspector = List.from(list);
    setState(() {
      listInspector = List.from(list);
    });
  }

  /// Emit list of [Inspector] to empty and delete all data from local
  void deleteAll() async {
    await InspectorService.deleteAll();
    setState(() {
      listInspector = [];
      masterListInspector = [];
    });
  }

  /// Emit toggle to change search mode
  void onChangeToSearch() {
    setState(() {
      isSearchMode = !isSearchMode;
      listInspector = List.from(masterListInspector);
    });
  }

  /// Emit list of [Inspector] when on change from search with give [value]
  void onSearchChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        listInspector = List.from(masterListInspector);
      });
      return;
    }
    var search = List<Inspector>.from(masterListInspector);
    search = search
        .where((element) => element.pathWithQuery.contains(value))
        .toList();
    setState(() {
      listInspector = search;
    });
  }

  /// Navigate to [MorphemeInspectorDetailPage]
  void navigateToDetail(BuildContext context, Inspector inspector) =>
      MorphemeInspectorDetailPage.navigate(context, inspector);

  @override
  void initState() {
    super.initState();
    getAllInspector();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeInspector(
      child: Scaffold(
        appBar: AppBar(
          title: isSearchMode
              ? TextField(onChanged: onSearchChanged, autofocus: true)
              : const Text('Morpheme Inspector'),
          actions: [
            IconButton(
              onPressed: onChangeToSearch,
              icon: Icon(isSearchMode ? Icons.close : Icons.search),
            ),
            IconButton(
              onPressed: deleteAll,
              icon: const Icon(Icons.delete),
            )
          ],
        ),
        body: ListView.separated(
          itemBuilder: (context, index) => ItemInspector(
            item: listInspector[index],
            onItemPressed: (item) => navigateToDetail(
              context,
              item,
            ),
          ),
          separatorBuilder: (_, __) =>
              Container(height: 1, color: Colors.grey[800]),
          itemCount: listInspector.length,
        ),
      ),
    );
  }
}
