import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Talker instance for logging throughout the app
final talker = Talker(
  logger: TalkerLogger(
    settings: TalkerLoggerSettings(
      level: LogLevel.debug,
      enableColors: defaultTargetPlatform != TargetPlatform.iOS,
    ),
  ),
  settings: TalkerSettings(
    timeFormat: TimeFormat.yearMonthDayAndTime,
  ),
);
