import 'package:flutter/foundation.dart';

class PagingState<T> {
  PagingState({
    required this.increment,
    this.page = 1,
    this.isLastPage = false,
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  final int increment;
  final int page;
  final bool isLastPage;
  final bool isLoading;
  final List<T> items;
  final dynamic error;

  bool get canLoadMore => !isLastPage && !isLoading && error == null;

  bool get isFirstLoading => isLoading && items.isEmpty;
  bool get isPagingLoading => isLoading && items.isNotEmpty;
  bool get hasItems => items.isNotEmpty;
  bool get hasErrorLoad => error != null && items.isEmpty;
  bool get hasErrorPagingLoad => error != null && items.isNotEmpty;
  bool get hasEmpty => error == null && items.isEmpty && !isLoading;

  PagingState<T> copyWith({
    int? increment,
    int? page,
    bool? isLastPage,
    bool? isLoading,
    List<T>? items,
    dynamic error,
  }) {
    return PagingState<T>(
      increment: increment ?? this.increment,
      page: page ?? this.page,
      isLastPage: isLastPage ?? this.isLastPage,
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PagingState<T> &&
        other.increment == increment &&
        other.page == page &&
        other.isLastPage == isLastPage &&
        other.isLoading == isLoading &&
        listEquals(other.items, items) &&
        other.error == error;
  }

  @override
  int get hashCode {
    return increment.hashCode ^
        page.hashCode ^
        isLastPage.hashCode ^
        isLoading.hashCode ^
        items.hashCode ^
        error.hashCode;
  }
}
