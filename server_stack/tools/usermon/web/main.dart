/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library usermon;

import 'dart:async';
import 'dart:html';
import 'package:logging/logging.dart';
import 'package:orf/model.dart' as or_model;
import 'package:orf/service.dart' as ORService;
import 'package:orf/service-html.dart' as ORTransport;

import 'package:usermon/view.dart' as view;
import 'package:usermon/config.dart' as config;

Map<int, view.AgentInfo> _userDataView = {};

Future main() async {
  Logger _log = Logger.root;
  _log.level = Level.FINE;
  _log.onRecord.listen(print);

  ///Basic setup.
  or_model.ClientConfiguration clientConfig =
      await new ORService.RESTConfiguration(
              config.defaultConfigServer, new ORTransport.Client())
          .clientConfig();

  ORService.CallFlowControl callFlowControl = new ORService.CallFlowControl(
      clientConfig.callFlowServerUri, config.token, new ORTransport.Client());

  ORTransport.WebSocketClient webSocketClient =
      new ORTransport.WebSocketClient();
  ORService.NotificationSocket notificationSocket;

  ORService.RESTUserStore userService = new ORService.RESTUserStore(
      clientConfig.userServerUri, config.token, new ORTransport.Client());

  ORService.RESTMessageStore messageStore = new ORService.RESTMessageStore(
      clientConfig.messageServerUri, config.token, new ORTransport.Client());

  webSocketClient
      .connect(Uri
          .parse('${clientConfig.notificationSocketUri}?token=${config.token}'))
      .then((_) {
    _log.info('WebSocketClient connect succeeded - NotificationSocket up');
  });

  notificationSocket = new ORService.NotificationSocket(webSocketClient);

  ///Prefetch data
  //Iterable<or_model.Call> calls = await callFlowControl.callList();

  //view.CallList callList = new view.CallList(calls, notificationSocket);

  //await callFlowControl.callList().then((Iterable<or_model.Call> calls) {
  //    querySelector('#call-list').replaceWith(callList.element);
  //  });

  Iterable<or_model.UserReference> users = await userService.list();
  querySelector('#user-list').replaceWith(new view.AgentInfoList(
          users, callFlowControl, userService, notificationSocket, messageStore)
      .element);
}
