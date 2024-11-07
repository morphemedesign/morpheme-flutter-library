import 'dart:typed_data';

import 'package:objectbox/objectbox.dart';

@Entity()
class CachedModel {
  CachedModel({
    required this.imageUrl,
    required this.image,
    required this.ttl,
  });

  @Id()
  int id = 0;

  @Index(type: IndexType.value)
  @Unique(onConflict: ConflictStrategy.replace)
  final String imageUrl;

  @Property(type: PropertyType.byteVector)
  final Uint8List image;

  final int ttl;
}
