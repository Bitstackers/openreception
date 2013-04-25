import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/logger.dart';
import '../classes/protocol.dart' as protocol;

@observable
class AgentInfo extends WebComponent {
  int active = 0;
  String activeLabel = 'aktive';
  String faceURL = '../images/face.jpg';
  int paused = 0;
  String pausedLabel = 'pause';

  DivElement divParent;
  DivElement divFace;
  TableElement table;

  void inserted(){
    divParent = this.query('[name="boxcontent"]');
    table = divParent.query('table');

    divFace = this.query('[name="face"]');

    _initialSetup();
    _registrateSubscribers();

    _resize();
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    divFace.style.left = '${divParent.client.width - divParent.client.height}px';
    divFace.style.width = '${divParent.client.height}px';

    num marginLeft = (divParent.client.height - table.client.height) / 1.5;
    num marginTop = (divParent.client.height - table.client.height) / 2;

    if (marginLeft < 1) {
      marginLeft = 0;
      marginTop = 0;
    }

    table.style.marginLeft = '${marginLeft}px';
    table.style.marginTop = '${marginTop}px';

    if (divParent.client.width < 150) {
      divFace.classes.add('hidden');
    } else {
      divFace.classes.remove('hidden');
    }
  }

  void _initialSetup() {
    new protocol.AgentList()
      ..onSuccess((data) {
        log.debug(data.toString());
        for (var agent in data['Agents']){
          switch(agent["state"]){
            case "busy":
            case "idle":
              active++;
              break;
            case "paused":
              paused++;
              break;
          }
        }
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
