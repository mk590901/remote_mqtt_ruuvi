// lib/models/trace.dart
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Parameter extends Equatable {
  final String name;
  final String value;

  const Parameter({required this.name, required this.value});

  @override
  List<Object> get props => [name, value];
}

class Trace extends Equatable {
  final String id;
  final String title;
  final bool isOnline;
  final DateTime createdAt;
  final List<Parameter> parameters;

  Trace({
    String? id,
    required this.title,
    required this.isOnline,
    required this.parameters,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Trace copyWith({
    String? title,
    bool? isOnline,
    List<Parameter>? parameters,
  }) {
    return Trace(
      id: id,
      title: title ?? this.title,
      isOnline: isOnline ?? this.isOnline,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt,
    );
  }

  Parameter? parameter(String name) {
    Parameter? result;
    for (int i = 0; i < parameters.length; i++) {
      if (parameters[i].name == name) {
        result = parameters[i];
      }
    }
    return result;
  }

  @override
  List<Object> get props => [id, title, createdAt, parameters];
}