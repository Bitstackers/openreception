import 'dart:async';
import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/commands.dart' as command;
import '../classes/logger.dart';
import '../classes/model.dart' as model;

class CallQueueItem extends WebComponent {
  model.Call call = model.nullCall;

  @observable int age = 0;

  void inserted() {
    age = new DateTime.now().difference(call.start).inSeconds.ceil();
    new Timer.periodic(new Duration(seconds:1), (_) => age++);
  }

  void pickupcallHandler() {
    log.debug('pickupcallHandler');
    command.pickupCall(call.id);
  }
}
