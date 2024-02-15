import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'cached_model.g.dart';

@HiveType(typeId: 0)
class CachedModel {
  CachedModel({
    required this.image,
    required this.ttl,
  });

  @HiveField(0)
  final Uint8List image;

  @HiveField(1)
  final int ttl;
}
