import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'json_status.dart';

class JsonResult extends Equatable {
  JsonResult({
    required this.status,
    required this.duration,
    this.errorMessage,
  });

  final JsonStatus status;
  final int duration;
  final String? errorMessage;

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'duration': duration,
      'error_message': errorMessage,
    };
  }

  factory JsonResult.fromMap(Map<String, dynamic> map) {
    return JsonResult(
      status: JsonStatus.fromString(map['status'] ?? ''),
      duration: map['duration']?.toInt() ?? 0,
      errorMessage: map['error_message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory JsonResult.fromJson(String source) =>
      JsonResult.fromMap(json.decode(source));

  JsonResult copyWith({
    JsonStatus? status,
    int? duration,
    String? errorMessage,
  }) {
    return JsonResult(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, duration, errorMessage];
}
