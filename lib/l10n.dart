import 'package:enterprise/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

export 'package:enterprise/l10n/generated/app_localizations.dart';
export 'package:enterprise/l10n/generated/app_localizations_en.dart';
export 'package:enterprise/l10n/generated/app_localizations_ms.dart';

/// Extension on [BuildContext] to provide easy access to localization
extension LocalizationUtil on BuildContext {
  /// Shorthand to access the `AppLocalizations` instance. Needs to be called
  /// within a `BuildContext` that has a `LocalizationsDelegate` registered.
  AppLocalizations get tr => AppLocalizations.of(this)!;
}
