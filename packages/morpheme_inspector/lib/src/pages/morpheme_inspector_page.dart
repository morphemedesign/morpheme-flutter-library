import 'package:flutter/material.dart';
import 'package:morpheme_inspector/src/pages/morpheme_inspector_detail_page.dart';
import 'package:morpheme_inspector/src/widgets/item_inspector.dart';
import 'package:morpheme_inspector/src/widgets/pagination/list_view_pagination.dart';
import 'package:morpheme_inspector/src/widgets/pagination/models/pagination_builder_delegate.dart';
import 'package:morpheme_inspector/src/widgets/pagination/models/paging_controller.dart';
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
  /// Controller for managing pagination of [Inspector] items.
  /// This controller handles the loading and appending of paginated data.
  final pagingController = PagingController<Inspector>();

  /// The maximum number of items to load per page.
  final int limit = 20;

  /// Flag used to toggle search mode.
  bool isSearchMode = false;

  /// The keyword used for searching inspectors.
  String? keyword;

  /// Handles the loading of paginated data.
  ///
  /// This method is triggered when a new page of data is requested.
  /// It calculates the offset based on the current [page] and the predefined [limit].
  /// It then fetches a list of [Inspector] objects from the [InspectorService].
  /// If the number of items fetched is less than the [limit], it appends the items
  /// as the last set of items to the [pagingController]. Otherwise, it appends
  /// the items normally.
  ///
  /// [page] The current page number being loaded.
  Future<void> onPagingLoad(int page) async {
    final offset = page * limit;
    final list = await InspectorService.getAll(
      keyword: keyword,
      limit: limit,
      offset: offset,
    );

    if (list.length < limit) {
      pagingController.appendLastItems(list);
    } else {
      pagingController.appendItems(list);
    }
  }

  /// Emit list of [Inspector] to empty and delete all data from local
  void deleteAll() async {
    await InspectorService.deleteAll();
    pagingController.reset();
  }

  /// Emit toggle to change search mode
  void onChangeToSearch() {
    setState(() {
      isSearchMode = !isSearchMode;
      pagingController.reset();
    });
  }

  /// Emit list of [Inspector] when on change from search with give [value]
  void onSearchChanged(String value) {
    keyword = value.isEmpty ? null : value;

    pagingController.reset();
  }

  /// Navigate to [MorphemeInspectorDetailPage]
  void navigateToDetail(BuildContext context, Inspector inspector) =>
      MorphemeInspectorDetailPage.navigate(context, inspector);

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
        body: ListViewPagination<Inspector>(
          pagingController: pagingController,
          onPagingLoad: onPagingLoad,
          separatorBuilder: (_, __) =>
              Container(height: 1, color: Colors.grey[800]),
          paginationBuilderDelegate: PaginationBuilderDelegate(
            builder: (context, item, index) => ItemInspector(
              item: item,
              onItemPressed: (item) => navigateToDetail(
                context,
                item,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
