import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/logger.dart';
import '../classes/notification.dart' as notify;
import '../classes/protocol.dart';

class AgentInfo extends WebComponent {
  int numOnline = 0, numActive = 0, numBusy = 0;

  void inserted(){
    //_initialSetup();
    _registrateSubscribers();
  }

  void _initialSetup() {
    new AgentList()
      ..onSuccess((data) {
        log.debug(data.toString());
      })
      ..onError(() {

      })
      ..send();
  }

  void _registrateSubscribers(){
    //When the time comes, that alice can handle agents.
    // Subscribe to AgentStatus changes, so this panel can be updated.
  }
}
