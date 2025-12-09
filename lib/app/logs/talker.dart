import 'dart:io';

import 'package:talker_flutter/talker_flutter.dart';

/// Talker instance for logging throughout the app
final talker = Talker(
  logger: TalkerLogger(
    settings: TalkerLoggerSettings(
      level: LogLevel.debug,
      enableColors: !Platform.isIOS, // Disable colors only on iOS
    ),
  ),
  settings: TalkerSettings(
    timeFormat: TimeFormat.yearMonthDayAndTime,
  ),
);
