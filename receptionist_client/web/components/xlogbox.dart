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

      while (messages.length > configuration.userLogSizeLimit){
        messages.removeLast();
      }
    }); //???? Can this be right? insert at index... why not AddFirst. Am i blind?
  }
}
