part of openreception.event;

abstract class OrganizationState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class OrganizationChange implements Event {

  final DateTime timestamp;

  String get eventName => _Key.organizationChange;

  final int orgID;
  final String state;

  OrganizationChange (this.orgID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {_Key.organizationID : this.orgID,
                _Key.state          : this.state};

    template[this.eventName] = body;

    return template;
  }

  OrganizationChange.fromMap (Map map) :
    this.orgID = map[this.eventName][_Key.organizationID],
    this.state = map[this.eventName][_Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[_Key.timestamp]);
}