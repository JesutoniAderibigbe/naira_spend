import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Sends `package:logging` records to the console in debug builds, and routes
/// uncaught Flutter and platform errors into `logging` too, so Marionette's
/// `get_logs` sees them.
void setUpLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name} ${record.loggerName}: ${record.message}'
      '${record.error == null ? '' : ' ${record.error}'}',
    );
  });

  final log = Logger('app');
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.severe(details.exceptionAsString(), details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.severe('Uncaught error', error, stack);
    return false;
  };
}
