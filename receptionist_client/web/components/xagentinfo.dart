import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/logger.dart';
import '../classes/protocol.dart' as protocol;

class AgentInfo extends WebComponent {
  @observable int active = 0;
  @observable int paused = 0;

  String       activeLabel = 'aktive';
  DivElement   divFace;
  DivElement   divParent;
  String       faceURL     = '../images/face.jpg';
  String       pausedLabel = 'pause';
  TableElement table;

  void inserted(){
    _queryElements();
    _registerEventListeners();
    _resize();
    _initialSetup();
    _registerSubscribers();
  }

  void _queryElements() {
    divParent = this.query('[name="boxcontent"]');
    table = divParent.query('table');
    divFace = this.query('[name="face"]');
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
    protocol.agentList()
    .then((protocol.Response response) {
        switch(response.status) {
          case protocol.Response.OK:
            for (var agent in response.data['Agents']) {
              switch(agent["state"]) {
                case "busy":
                case "idle":
                  active++;
                  break;
                case "paused":
                  paused++;
                  break;
              }
            }
            break;
          default:
          //TODO How to handle this?
        }
      })
      .catchError((e) {
        log.critical('xagent Error: ${e.toString()}');
      });
  }

  void _registerEventListeners() {
    window.onResize.listen((_) => _resize());
  }

  void _registerSubscribers(){
    //When the time comes, that alice can handle agents.
    // Subscribe to AgentStatus changes, so this panel can be updated.
  }
}
