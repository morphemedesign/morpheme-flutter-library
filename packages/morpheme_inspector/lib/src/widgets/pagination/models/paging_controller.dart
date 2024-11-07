import 'package:flutter/material.dart';

import 'paging_state.dart';

class PagingController<T> extends ValueNotifier<PagingState<T>> {
  PagingController() : super(PagingState(increment: 1, isLoading: true));

  bool _disposed = false;

  void reset() {
    value = PagingState(increment: value.increment + 1);
  }

  void setLoading() {
    value = value.copyWith(isLoading: true);
  }

  void updateItem({required T oldItem, required T newItem}) {
    final indexOfItem = value.items.indexOf(oldItem);
    final List<T> list = List.from(value.items);
    list[indexOfItem] = newItem;
    value = value.copyWith(items: list);
  }

  void removeItem({required T item}) {
    final List<T> list = List.from(value.items)..remove(item);
    value = value.copyWith(items: list);
  }

  void replaceItems({
    required List<T> items,
    bool nextPage = false,
    bool? isLastPage,
  }) {
    value = value.copyWith(
      items: items,
      isLoading: false,
      page: nextPage && !(isLastPage ?? false) ? value.page + 1 : value.page,
      isLastPage: isLastPage,
    );
  }

  void insertItemAtFirst(T item) {
    value = value.copyWith(
      isLoading: false,
      items: [item, ...value.items],
    );
  }

  void insertItemAtLast(T item) {
    value = value.copyWith(
      isLoading: false,
      items: [...value.items, item],
    );
  }

  void appendItems(List<T> items) {
    value = value.copyWith(
      page: value.page + 1,
      isLoading: false,
      items: [...value.items, ...items],
    );
  }

  void appendLastItems(List<T> items) {
    value = value.copyWith(
      isLastPage: true,
      isLoading: false,
      items: [...value.items, ...items],
    );
  }

  void setError(dynamic error) {
    value = value.copyWith(
      isLoading: false,
      error: error,
    );
  }

  @override
  void dispose() {
    if (!_disposed) {
      super.dispose();
    }
    _disposed = true;
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (!_disposed) {
      super.addListener(listener);
    }
  }

  @override
  bool get hasListeners => !_disposed && super.hasListeners;
}
