/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

import 'dart:html';

import 'package:polymer/polymer.dart';

import '../classes/logger.dart';
import '../classes/protocol.dart' as protocol;

@CustomTag('agent-info')
class AgentInfo extends PolymerElement {
  @observable int active = 0;
  @observable int paused = 0;

  String       activeLabel = 'aktive';
  DivElement   divFace;
  DivElement   divParent;
  String       faceURL     = 'images/face.jpg';
  String       pausedLabel = 'pause';
  TableElement table;

  bool get applyAuthorStyles => true; //Applies external css styling to component.

  void created() {
    super.created();
    _initialSetup();
    _registerEventListeners();
  }

  void inserted() {
    _queryElements();
    _resize();
  }

  void _queryElements() {
    divParent = getShadowRoot('agent-info').query('[name="boxcontent"]');
    table = divParent.query('table');
    divFace = getShadowRoot('agent-info').query('[name="face"]');
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
    protocol.agentList().then((protocol.Response response) {
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
      log.critical('AgentInfo ERROR ${e.toString()}');
    });
  }

  void _registerEventListeners() {
    window.onResize.listen((_) => _resize());
  }
}
