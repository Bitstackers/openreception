/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model;

class FreeSWITCHCDREntry {
  String uuid = '';
  bool inbound = false;
  int receptionId = Reception.noID;
  String extension = '';
  int duration = -1;
  int waitTime = -1;
  DateTime startedAt = Util.never;

  int owner = User.noID;
  int contact_id = Contact.noID;

  Map json = {};

  /**
   * Default empty constructor
   */
  FreeSWITCHCDREntry.empty();

  FreeSWITCHCDREntry.fromJson(Map this.json) {
    Map variables = json['variables'];

    uuid = variables['uuid'];
    inbound = variables['direction'] == 'inbound';
    receptionId = int.parse(variables[ORPbxKey.receptionId]);

    if (json['callflow'] is List) {
      List<Map> callFlow = json['callflow'];
      extension = callFlow.firstWhere((Map map) => map['profile_index'] == '1')['caller_profile']
          ['destination_number'];
    } else {
      extension = json['callflow']['caller_profile']['destination_number'];
    }

    duration = int.parse(variables['billsec']);
    waitTime = int.parse(variables['waitsec']);
    startedAt =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(json['variables']['start_epoch']) * 1000);

    if (variables.containsKey('owner')) {
      owner = int.parse(variables['owner']);
    }

    if (variables.containsKey(ORPbxKey.contactId)) {
      contact_id = int.parse(variables[ORPbxKey.contactId]);
    }
  }
}
