part of openreception.event;

/**
 * 'Enum' representing different outcomes of an [Organization] change.
 */
abstract class OrganizationState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class OrganizationChange implements Event {

  final DateTime timestamp;

  String get eventName => Key.organizationChange;

  final int orgID;
  final String state;

  OrganizationChange (this.orgID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {Key.organizationID : this.orgID,
                Key.state          : this.state};

    template[this.eventName] = body;

    return template;
  }

  OrganizationChange.fromMap (Map map) :
    this.orgID = map[Key.organizationChange ][Key.organizationID],
    this.state = map[Key.organizationChange ][Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}