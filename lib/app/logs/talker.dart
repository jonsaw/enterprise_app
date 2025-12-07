import 'package:talker_flutter/talker_flutter.dart';

/// Talker instance for logging throughout the app
final talker = Talker(
  logger: TalkerLogger(settings: TalkerLoggerSettings(level: LogLevel.debug)),
  settings: TalkerSettings(
    timeFormat: TimeFormat.yearMonthDayAndTime,
  ),
);
