import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum LogLevel { debug, info, warning, error, critical }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  static File? _logFile; // Changed to nullable
  static bool _initialized = false;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  static Future<void> initialize() async {
    if (!_initialized) {
      if (!kIsWeb) { // Check if not on web
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String logDirPath = '${appDocDir.path}/logs';
        
        // Create logs directory if it doesn't exist
        final Directory logDir = Directory(logDirPath);
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
        
        // Create log file with current date
        final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _logFile = File('$logDirPath/app_log_$today.log');
      }
      _initialized = true;
    }
  }

  Future<void> log(String message, {LogLevel level = LogLevel.info}) async {
    if (!_initialized) await initialize();
    
    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final String logEntry = '[$now][${level.toString().split('.').last.toUpperCase()}] $message\n';
    
    // Always print to console
    print(logEntry);

    if (!kIsWeb && _logFile != null) { // Check if not on web and _logFile is initialized
      try {
        await _logFile!.writeAsString(logEntry, mode: FileMode.append);
      } catch (e) {
        print('Failed to write to log file: $e');
      }
    }
  }

  Future<void> logError(String message, {dynamic error, StackTrace? stackTrace}) async {
    String errorMessage = message;
    if (error != null) {
      errorMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      errorMessage += '\nStackTrace: $stackTrace';
    }
    await log(errorMessage, level: LogLevel.error);
  }

  Future<void> logInfo(String message) async {
    await log(message, level: LogLevel.info);
  }
  Future<void> logWarning(String message) async {
    await log(message, level: LogLevel.warning);
  }
}
