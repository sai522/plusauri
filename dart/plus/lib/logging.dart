library plus.logging;

import 'package:logging/logging.dart';
// custom <additional imports>

plusLogFine(Logger logger, makeMessage) {
  if (logger.level <= Level.FINE) logger.fine(makeMessage());
}

plusLogFiner(Logger logger, makeMessage) {
  if (logger.level <= Level.FINER) logger.finer(makeMessage());
}

plusLogWarning(Logger logger, makeMessage) {
  if (logger.level <= Level.WARNING) logger.warning(makeMessage());
}

plusLogAlways(Logger logger, makeMessage) {
  print(makeMessage());
  /*  final was = Logger.root.level;
  Logger.root.level = Level.FINER;
  logger.finer(makeMessage());
  Logger.root.level = was;*/
}


// end <additional imports>

// custom <library logging>
// end <library logging>

