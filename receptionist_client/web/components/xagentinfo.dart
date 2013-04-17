import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/logger.dart';
import '../classes/notification.dart' as notify;
import '../classes/protocol.dart' as protocol;

@observable
class AgentInfo extends WebComponent {
  int numOnline = 0, numActive = 0, numBusy = 0;

  DivElement divParent;
  DivElement divTotal;
  DivElement divActive;
  DivElement divSleep;
  DivElement divFace;

  ImageElement imgTotal;
  ImageElement imgActive;
  ImageElement imgSleep;
  ImageElement imgFace;

  void inserted(){
    divParent = this.query('[name="boxcontent"]');

    divTotal = this.query('[name="total"]');
    imgTotal = divTotal.query('img');

    divActive = this.query('[name="active"]');
    imgActive = divActive.query('img');

    divSleep = this.query('[name="sleep"]');
    imgSleep = divSleep.query('img');

    divFace = this.query('[name="face"]');
    imgFace = divFace.query('img');

    _initialSetup();
    _registrateSubscribers();

    _resize();
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    divFace.style.left = '${divParent.client.width - divParent.client.height}px';
    divFace.style.width = '${divParent.client.height}px';

    imgFace.style.height = '${divFace.client.height}px';
    imgFace.style.width = '${divFace.client.width}px';

    num partSize = (divParent.client.width - divFace.client.width) / 3;

    divTotal.style.width = '${partSize}px';
    imgTotal.style.height = '${0.7 * divTotal.client.height}px';
    imgTotal.style.width = '${imgTotal.client.height}px';
    imgTotal.style.margin = '${0.15 * divTotal.client.height}px ${0.1 * partSize}px';

    divActive.style.left = '${partSize}px';
    divActive.style.width = '${partSize}px';
    imgActive.style.height = '${0.7 * divActive.client.height}px';
    imgActive.style.width = '${imgActive.client.height}px';
    imgActive.style.margin = '${0.15 * divActive.client.height}px';

    divSleep.style.left = '${partSize * 2}px';
    divSleep.style.width = '${partSize}px';
    imgSleep.style.height = '${0.7 * divSleep.client.height}px';
    imgSleep.style.width = '${imgSleep.client.height}px';
    imgSleep.style.margin = '${0.15 * divSleep.client.height}px';
  }

  void _initialSetup() {
    int online = 0, Active = 0, Busy = 0;

    new protocol.AgentList()
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
