import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';
// custom <additional imports>
// end <additional imports>


main() {
  Logger.root.onRecord.listen((LogRecord r) =>
    print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.FINEST;
  initPolymer().run(() {
    Polymer.onReady.then((var _) {
// custom <timelineNav main>
// end <timelineNav main>

    });
  });
}

// custom <additional code>
// end <additional code>

