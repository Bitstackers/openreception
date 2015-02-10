/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of view;

class AgentInfo {
  int              active      = 0;
  TableCellElement activeTD;
  Box              box;
  DivElement       divFace;
  DivElement       divParent;
  DivElement       element;
  TableCellElement get activeLabelTD => this.element.querySelector('#agent-info-stats-active-label');
  TableCellElement get pausedLabelTD => this.element.querySelector('#agent-info-stats-paused-label');
  String           faceURL     = 'images/face.png';
  int              paused      = 0;
  TableCellElement pausedTD;
  ImageElement     portrait;
  TableElement     table;

  Element get userStatusElement => element.querySelector('#agent-info-status');

  AgentInfo(DivElement this.element) {
    divParent = element.querySelector('#agent-info-stats');
    table = divParent.querySelector('table');
    divFace = divParent.querySelector('#agent-info-portrait');
    portrait = (divFace.querySelector('#agent-info-portrait-image') as ImageElement)
      ..src = faceURL;

    activeTD = table.querySelector('#agent-info-stats-active');
    pausedTD = table.querySelector('#agent-info-stats-paused');

    box = new Box.noChrome(element, divParent);

    initialSetup();

    registerEventListeners();
    resize();

    new Future.delayed(new Duration(seconds: 1, milliseconds: 500), () {
      if(model.User.currentUser != null) {
        //FIXME: implement an photoUrl in the User class in the framework.
        portrait.src = model.User.currentUser.toJson()['remote_attributes']['picture'];

        Service.Call.userState(model.User.currentUser.ID).then((model.UserStatus newUserStatus) {
          this._updateUserState(newUserStatus);
        });
      }
    }).catchError((error) {
      log.error('components.AgentInfo() Updating Agent image failed with "${error}"');
    });

    userStatusElement.children = [Icon.Unknown];

    event.bus.on(event.userStatusChanged).listen(_updateUserState);

    setupLabels();
    print (activeLabelTD.text);
  }

  void setupLabels() {
    this.activeLabelTD.text = ': ${Label.Active}';
    this.pausedLabelTD.text = ': ${Label.Paused}';
  }

  _updateUserState (model.UserStatus newUserStatus) {
    switch (newUserStatus.state) {
      case (ORModel.UserState.Unknown):
        userStatusElement.children = [Icon.Unknown];
        break;

      case (ORModel.UserState.Idle):
        userStatusElement.children = [Icon.Idle];
        break;

      case (ORModel.UserState.Paused):
        userStatusElement.children = [Icon.Pause];
        break;

      default:
        userStatusElement.children = [Icon.Busy];
        break;
    }
  }

  void resize() {
    divFace.style
      ..left = '${divParent.client.width - divParent.client.height}px'
      ..width = '${divParent.client.height}px';

    double marginLeft = (divParent.client.height - table.client.height) / 1.5;
    double marginTop = (divParent.client.height - table.client.height) / 2;

    if (marginLeft < 1.0) {
      marginLeft = 0.0;
      marginTop = 0.0;
    }

    table.style
      ..marginLeft = '${marginLeft}px'
      ..marginTop = '${marginTop}px';

    divFace.classes.toggle('hidden', divParent.client.width < 150);
  }

  void initialSetup() {
    Service.Call.userStateList().then((Iterable<model.UserStatus> userStates) {
      this.active = userStates.where((model.UserStatus user)
          => user.state != ORModel.UserState.Idle).length;

      this.paused= userStates.where((model.UserStatus user)
          => user.state != ORModel.UserState.Paused).length;

    })
    .catchError((error) => log.critical('AgentInfo ERROR ${error.toString()}'))
    .whenComplete(updateCounters);
  }

  void registerEventListeners() {
    window.onResize.listen((_) => resize());
  }

  void updateCounters() {
    activeTD.text = active.toString();
    pausedTD.text = paused.toString();
  }
}
