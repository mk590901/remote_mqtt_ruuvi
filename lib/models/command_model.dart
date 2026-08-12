import 'dart:convert';

class Command {
  final String command;
  final String data;

  Command({required this.command, required this.data});

  // Convert Command to JSON
  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'data': data,
    };
  }

  // Create Command from JSON
  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      command: json['command'] as String,
      data: json['data'] as String,
    );
  }

  // Encode to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Decode from JSON string
  static Command fromJsonString(String jsonString) {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return Command.fromJson(jsonMap);
  }

}
