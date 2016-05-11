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

part of openreception.framework.model;

class ReceptionAttributeChange implements ObjectChange {
  final ChangeType changeType;
  ObjectType get objectType => ObjectType.receptionAttribute;
  final int cid;
  final int rid;

  /**
   *
   */
  ReceptionAttributeChange(this.changeType, this.cid, this.rid);

  /**
   *
   */
  static ReceptionAttributeChange decode(Map map) =>
      new ReceptionAttributeChange(
          changeTypeFromString(map[Key.change]), map[Key.cid], map[Key.rid]);

  /**
   *
   */
  ReceptionAttributeChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[Key.change]),
        cid = map[Key.cid],
        rid = map[Key.rid];

  /**
   *
   */
  Map toJson() => {
        Key.change: changeTypeToString(changeType),
        Key.type: objectTypeToString(objectType),
        Key.cid: cid,
        Key.rid: rid
      };
}

class ReceptionAttributes {
  static const String noId = '';

  int cid = BaseContact.noId;
  int receptionId = Reception.noId;

  List<PhoneNumber> phoneNumbers = [];
  List<MessageEndpoint> endpoints = [];

  List<String> backupContacts = [];
  List<String> messagePrerequisites = [];

  List<String> tags = new List<String>();
  List<String> emailaddresses = new List<String>();
  List<String> handling = new List<String>();
  List<String> workhours = new List<String>();
  List<String> titles = [];
  List<String> responsibilities = [];
  List<String> relations = [];
  List<String> departments = [];
  List<String> infos = [];

  static ReceptionAttributes decode(Map map) =>
      new ReceptionAttributes.fromMap(map);

  Map toJson() => {
        Key.cid: cid,
        Key.rid: receptionId,
        Key.departments: departments,
        Key.phones: new List<Map>.from(phoneNumbers.map((p) => p.toJson())),
        Key.endpoints: new List<Map>.from(endpoints.map((e) => e.toJson())),
        Key.backup: backupContacts,
        Key.emailaddresses: emailaddresses,
        Key.handling: handling,
        Key.workhours: workhours,
        Key.tags: tags,
        Key.infos: infos,
        Key.titles: titles,
        Key.relations: relations,
        Key.responsibilities: responsibilities,
        Key.messagePrerequisites: messagePrerequisites
      };

  /**
   *
   */
  ReceptionAttributes.fromMap(Map map)
      : phoneNumbers =
            new List<PhoneNumber>.from(map[Key.phones].map(PhoneNumber.decode)),
        endpoints = new List<MessageEndpoint>.from(
            map[Key.endpoints].map(MessageEndpoint.decode)),
        receptionId = map[Key.rid],
        cid = map[Key.cid],
        departments = map[Key.departments] as List<String>,
        messagePrerequisites = map[Key.messagePrerequisites] as List<String>,
        backupContacts = map[Key.backup] as List<String>,
        emailaddresses = map[Key.emailaddresses] as List<String>,
        handling = map[Key.handling] as List<String>,
        workhours = map[Key.workhours] as List<String>,
        tags = map[Key.tags] as List<String>,
        infos = map[Key.infos] as List<String>,
        titles = map[Key.titles] as List<String>,
        relations = map[Key.relations] as List<String>,
        responsibilities = map[Key.responsibilities] as List<String>;

  /**
   * [Contact] empty constructor.
   */
  ReceptionAttributes.empty();

  bool get isEmpty => cid == BaseContact.noId;
  bool get isNotEmpty => !isEmpty;
}
