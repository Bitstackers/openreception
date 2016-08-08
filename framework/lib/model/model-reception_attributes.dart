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
  @override
  final ChangeType changeType;
  @override
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
          changeTypeFromString(map[key.change]), map[key.cid], map[key.rid]);

  /**
   *
   */
  ReceptionAttributeChange.fromJson(Map map)
      : changeType = changeTypeFromString(map[key.change]),
        cid = map[key.cid],
        rid = map[key.rid];

  /**
   *
   */
  @override
  Map toJson() => {
        key.change: changeTypeToString(changeType),
        key.type: objectTypeToString(objectType),
        key.cid: cid,
        key.rid: rid
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
        key.cid: cid,
        key.rid: receptionId,
        key.departments: departments,
        key.phones: new List<Map>.from(phoneNumbers.map((p) => p.toJson())),
        key.endpoints: new List<Map>.from(endpoints.map((e) => e.toJson())),
        key.backup: backupContacts,
        key.emailaddresses: emailaddresses,
        key.handling: handling,
        key.workhours: workhours,
        key.tags: tags,
        key.infos: infos,
        key.titles: titles,
        key.relations: relations,
        key.responsibilities: responsibilities,
        key.messagePrerequisites: messagePrerequisites
      };

  /**
   *
   */
  ReceptionAttributes.fromMap(Map map)
      : phoneNumbers =
            new List<PhoneNumber>.from(map[key.phones].map(PhoneNumber.decode)),
        endpoints = new List<MessageEndpoint>.from(
            map[key.endpoints].map(MessageEndpoint.decode)),
        receptionId = map[key.rid],
        cid = map[key.cid],
        departments = map[key.departments] as List<String>,
        messagePrerequisites = map[key.messagePrerequisites] as List<String>,
        backupContacts = map[key.backup] as List<String>,
        emailaddresses = map[key.emailaddresses] as List<String>,
        handling = map[key.handling] as List<String>,
        workhours = map[key.workhours] as List<String>,
        tags = map[key.tags] as List<String>,
        infos = map[key.infos] as List<String>,
        titles = map[key.titles] as List<String>,
        relations = map[key.relations] as List<String>,
        responsibilities = map[key.responsibilities] as List<String>;

  /**
   * [Contact] empty constructor.
   */
  ReceptionAttributes.empty();

  bool get isEmpty => cid == BaseContact.noId;
  bool get isNotEmpty => !isEmpty;
}
