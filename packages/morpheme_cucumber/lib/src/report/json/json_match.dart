import 'dart:convert';

import 'package:equatable/equatable.dart';

class JsonMatch extends Equatable {
  JsonMatch({
    required this.location,
  });

  final String location;

  Map<String, dynamic> toMap() {
    return {
      'location': location,
    };
  }

  factory JsonMatch.fromMap(Map<String, dynamic> map) {
    return JsonMatch(
      location: map['location'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory JsonMatch.fromJson(String source) =>
      JsonMatch.fromMap(json.decode(source));

  JsonMatch copyWith({
    String? location,
  }) {
    return JsonMatch(
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [location];
}
