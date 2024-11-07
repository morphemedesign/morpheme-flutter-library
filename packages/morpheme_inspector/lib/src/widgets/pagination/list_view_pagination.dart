import 'package:flutter/material.dart';
import 'package:morpheme_inspector/src/widgets/pagination/models/pagination_builder_delegate.dart';
import 'package:morpheme_inspector/src/widgets/pagination/models/paging_controller.dart';
import 'package:morpheme_inspector/src/widgets/pagination/models/paging_state.dart';

class ListViewPagination<T> extends StatefulWidget {
  const ListViewPagination({
    required this.pagingController,
    required this.onPagingLoad,
    required this.paginationBuilderDelegate,
    super.key,
    this.separatorBuilder,
    this.padding,
    this.shrinkWrap = false,
    this.onRefresh,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.initialLoad = true,
    this.canRefresh = true,
  });

  final bool initialLoad;
  final PagingController<T> pagingController;
  final void Function(int page) onPagingLoad;
  final PaginationBuilderDelegate<T> paginationBuilderDelegate;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final Future<void> Function()? onRefresh;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool canRefresh;

  @override
  State<ListViewPagination<T>> createState() => _ListViewPaginationState<T>();
}

class _ListViewPaginationState<T> extends State<ListViewPagination<T>> {
  @override
  void initState() {
    super.initState();
    if (widget.initialLoad) {
      widget.pagingController.setLoading();
      widget.onPagingLoad(widget.pagingController.value.page);
    }
    WidgetsBinding.instance.endOfFrame.then(
      (value) {
        widget.pagingController.addListener(watchPagingController);
      },
    );
  }

  @override
  void dispose() {
    widget.pagingController.removeListener(watchPagingController);
    super.dispose();
  }

  void _pagingLoad() {
    if (widget.pagingController.value.isLoading) return;
    widget.pagingController.setLoading();
    widget.onPagingLoad(widget.pagingController.value.page);
  }

  void watchPagingController() {
    if (widget.pagingController.value.page == 1 &&
        widget.pagingController.value.canLoadMore &&
        widget.pagingController.value.items.isEmpty) {
      _pagingLoad();
    }
  }

  bool _onNotification(ScrollNotification notification, PagingState state) {
    final nextPageTrigger = 0.8 * notification.metrics.maxScrollExtent;
    if (notification.metrics.pixels > nextPageTrigger && state.canLoadMore) {
      _pagingLoad();
    }
    return true;
  }

  int _getLength(PagingState state) {
    if (state.hasErrorPagingLoad || state.isPagingLoading) {
      return state.items.length + 1;
    } else {
      return state.items.length;
    }
  }

  Widget _getItemBuilder(
    BuildContext context,
    PagingState state,
    int index,
  ) {
    if (state.hasErrorPagingLoad && index == state.items.length) {
      return widget.paginationBuilderDelegate.errorPagingBuilder
              ?.call(context, state.error) ??
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: IconButton(
                onPressed: _pagingLoad,
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
    }

    if (state.isPagingLoading && index == state.items.length) {
      return widget.paginationBuilderDelegate.loadingBuilder?.call(context) ??
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
    }
    return widget.paginationBuilderDelegate
        .builder(context, state.items[index], index);
  }

  Future<void> onRefresh() async {
    widget.pagingController.reset();
    await widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PagingState<T>>(
      valueListenable: widget.pagingController,
      builder: (context, value, child) {
        if (value.isFirstLoading) {
          return Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.paginationBuilderDelegate.firstLoadingBuilder
                    ?.call(context) ??
                const Center(
                  child: CircularProgressIndicator(),
                ),
          );
        } else if (value.hasEmpty) {
          return _RefreshIndicator(
            canRefresh:
                widget.canRefresh && widget.scrollDirection == Axis.vertical,
            onRefresh: onRefresh,
            isChildScrollable: false,
            child:
                widget.paginationBuilderDelegate.emptyBuilder?.call(context) ??
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('No data found'),
                      ),
                    ),
          );
        } else if (value.hasErrorLoad) {
          return _RefreshIndicator(
            canRefresh:
                widget.canRefresh && widget.scrollDirection == Axis.vertical,
            onRefresh: onRefresh,
            isChildScrollable: false,
            child: widget.paginationBuilderDelegate.errorBuilder
                    ?.call(context, value.error) ??
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(value.error.toString()),
                  ),
                ),
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) =>
              _onNotification(notification, value),
          child: _RefreshIndicator(
            canRefresh:
                widget.canRefresh && widget.scrollDirection == Axis.vertical,
            onRefresh: onRefresh,
            child: widget.separatorBuilder == null
                ? ListView.builder(
                    physics: widget.physics,
                    padding: widget.padding,
                    scrollDirection: widget.scrollDirection,
                    shrinkWrap: widget.shrinkWrap,
                    itemBuilder: (context, index) =>
                        _getItemBuilder(context, value, index),
                    itemCount: _getLength(value),
                  )
                : ListView.separated(
                    physics: widget.physics,
                    padding: widget.padding,
                    scrollDirection: widget.scrollDirection,
                    shrinkWrap: widget.shrinkWrap,
                    itemBuilder: (context, index) =>
                        _getItemBuilder(context, value, index),
                    separatorBuilder: widget.separatorBuilder!,
                    itemCount: _getLength(value),
                  ),
          ),
        );
      },
    );
  }
}

class _RefreshIndicator extends StatelessWidget {
  const _RefreshIndicator({
    required this.child,
    required this.onRefresh,
    this.canRefresh = true,
    this.isChildScrollable = true,
  });

  final bool canRefresh;
  final Widget child;
  final bool isChildScrollable;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (!canRefresh) return child;
    if (!isChildScrollable) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: child,
              ),
            ),
          );
        },
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
