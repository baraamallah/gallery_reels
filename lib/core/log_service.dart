import 'package:flutter/foundation.dart';

enum LogLevel { info, warning, error, verbose }

class LogService {
  static final LogService instance = LogService._();
  LogService._();

  final List<String> _logs = [];

  void log(String message, {LogLevel level = LogLevel.info}) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.substring(0, 12);
    final prefix = level.name.toUpperCase();
    final logEntry = '[$timestamp] [$prefix] $message';
    
    _logs.add(logEntry);
    if (_logs.length > 2000) _logs.removeAt(0);
    
    debugPrint(logEntry);
  }

  void info(String message) => log(message, level: LogLevel.info);
  void warn(String message) => log(message, level: LogLevel.warning);
  void verbose(String message) => log(message, level: LogLevel.verbose);

  void error(String message, [dynamic error, StackTrace? stack]) {
    final timestamp = DateTime.now().toIso8601String().split('T').last.substring(0, 12);
    final logEntry = '[$timestamp] [ERROR] $message\nError: $error\nStack: $stack';
    
    _logs.add(logEntry);
    if (_logs.length > 2000) _logs.removeAt(0);
    
    debugPrint(logEntry);
  }

  String get allLogs => _logs.join('\n');
  void clear() => _logs.clear();
}
