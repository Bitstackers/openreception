import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/logger.dart';
import '../classes/notification.dart' as notify;
import '../classes/protocol.dart';

@observable
class AgentInfo extends WebComponent {
  int numOnline = 0, numActive = 0, numBusy = 0;

  void inserted(){
    _initialSetup();
    _registrateSubscribers();
  }

  void _initialSetup() {
    int online = 0, Active = 0, Busy = 0;

    new AgentList()
      ..onSuccess((data) {
        log.debug(data.toString());
        for (var agent in data['Agents']){
          switch(agent["state"]){
            case "idle":
              online++;
              Active++;
              break;
            case "busy":
            case "paused":
              online++;
              Busy++;
              break;
          }
        }
        numOnline = online;
        numActive = Active;
        numBusy = Busy;
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
