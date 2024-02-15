import 'package:flutter/material.dart';
import 'package:morpheme_cached_network_image/src/morpheme_cached_network_image.dart';

void main(List<String> args) {
  MorphemeCachedNetworkImage(
    imageUrl: 'https://picsum.photos/id/2/200',
    loadingBuilder: (context) => const CircularProgressIndicator(),
    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
  );
}
