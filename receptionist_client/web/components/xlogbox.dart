import 'dart:html';

import 'package:logging/logging.dart';
import 'package:web_ui/web_ui.dart';

import '../classes/configuration.dart';
import '../classes/logger.dart';

class LogBox extends WebComponent {
  List<UserlogRecord> messages = toObservable(new List<UserlogRecord>());

  void inserted() {
    log.onUserlogMessage.listen((record) {
      messages.insert(0, record);
      // TODO: change messages to a Queue or ListQueue as soon as support for
      // for these are added to web_ui toObservable().

      while (messages.length > configuration.userLogSizeLimit){
        messages.removeLast();
      }
    });
  }
}
