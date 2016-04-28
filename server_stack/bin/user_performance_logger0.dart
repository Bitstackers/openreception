/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/**
 * The OR-Stack command-line event logger.
 */
library openreception.user_socket_logger;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

//import 'package:openreception.server/configuration.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:openreception.framework/event.dart' as event;

import 'package:openreception.framework/model.dart' as model;

// import 'package:openreception_framework/service.dart' as service;
// import 'package:openreception_framework/service-io.dart' as transport;

final Map<int, String> _userNameCache = {};
final DateFormat RFC3339 = new DateFormat('yyyy-MM-dd');

class AgentPause {
  final DateTime start;
  final DateTime stop;
  AgentPause(this.start, this.stop);
}

class AgentTimeline {
  final int uid;
  List<event.Event> _events = [];
  bool _sorted = false;

  AgentTimeline(this.uid);

  void addEvent(event.Event e) {
    _events.add(e);
    _sorted = false;
  }

  void sortEvents() {
    if (_sorted) {
      return;
    }

    _events.sort((e1, e2) => e1.timestamp.compareTo(e2.timestamp));
    _sorted = true;
  }

  String eventString() =>
      '  events:\n' + _events.map((e) => '  - ${_eventToString(e)}').join('\n');

  String _eventToString(event.Event e) =>
      '${e.timestamp}: ${_eventTypeToString(e)}';

  String _eventTypeToString(event.Event e) {
    if (e is event.CallEvent) {
      String dir = e.call.inbound ? ' inbound ' : ' outbound ';

      return e.eventName + dir + e.call.ID;
    } else if (e is event.UserState) {
      String state = e.status.paused ? ' pause ' : ' unpause ';
      return e.eventName + state;
    } else if (e is event.MessageChange) {
      return e.eventName + e.state;
    } else {
      return e.eventName;
    }
  }

  String toString() => 'uid:$uid\n'
      'pauses:'
      '${eventString()}';
}

Future main(List<String> args) async {
  Map<int, AgentTimeline> _agentTimelines = {};

  // transport.WebSocketClient client = new transport.WebSocketClient();
  // await client.connect(Uri.parse(
  //     '${config.configserver.notificationSocketUri}?token=${config.authServer.serverToken}'));
  //
  // service.NotificationSocket notificationSocket =
  //     new service.NotificationSocket(client);
  // service.RESTUserStore userStore = new service.RESTUserStore(
  //     config.configserver.userServerUri,
  //     config.authServer.serverToken,
  //     new transport.Client());
  //
  // await userStore.list().then((Iterable<model.User> users) {
  //   users.forEach((user) {
  //     _userNameCache[user.id] = user.name;
  //   });
  // });

  dispatchEvent(event.Event e) async {
    int uid = -1;
    if (e is event.CallEvent) {
      model.Call call = e.call;
      uid = call.assignedTo;
    } else if (e is event.MessageChange) {
      uid = e.modifierUid;
    } else if (e is event.ClientConnectionState) {
      uid = e.conn.userID;
    } else if (e is event.UserState) {
      uid = e.status.userId;
    } else if (e is event.PeerState ||
        e is event.ContactChange ||
        e is event.CalendarChange ||
        e is event.ReceptionChange ||
        e is event.OrganizationChange ||
        e is event.UserChange) {
      //Ignore these events.
      return;
    }

    if (uid == -1) {
      print('Unhandled event type: ${e.eventName}');
      return;
    }

    if (!_agentTimelines.containsKey(uid)) {
      _agentTimelines[uid] = new AgentTimeline(uid);
    }

    _agentTimelines[uid].addEvent(e);
  }

  // notificationSocket.eventStream.listen((event.Event e) {
  //   try {
  //     dispatchEvent(e);
  //   } catch (e, s) {
  //     print(e);
  //     print(s);
  //   }
  // });

  if (args.isNotEmpty) {
    args.forEach((arg) {
      print('Loading data from file $arg');
      List<String> lines = new File(arg).readAsLinesSync();

      lines.forEach((String line) {
        Map json = JSON.decode(line);
        event.Event e = new event.Event.parse(json);
        try {
          dispatchEvent(e);
        } catch (e, s) {
          print(e);
          print(s);
        }
      });
    });
  }

  await new Future.delayed(new Duration(seconds: 1));
  _agentTimelines.values.forEach((AgentTimeline atl) {
    atl.sortEvents();

    print(atl);
  });
}
