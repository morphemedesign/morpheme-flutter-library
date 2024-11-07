import 'package:flutter/material.dart';

class PaginationBuilderDelegate<T> {
  PaginationBuilderDelegate({
    required this.builder,
    this.firstLoadingBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.errorPagingBuilder,
  });

  final Widget Function(BuildContext context, T item, int index) builder;
  final Widget Function(BuildContext context)? firstLoadingBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;
  final Widget Function(BuildContext context, dynamic error)?
      errorPagingBuilder;
}
