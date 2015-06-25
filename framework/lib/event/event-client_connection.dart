part of openreception.event;

class ClientConnectionState implements Event {

  final DateTime timestamp;

  final ClientConnection conn;
  String get eventName => Key.connectionState;

  ClientConnectionState (ClientConnection this.conn) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.connection(this);

  ClientConnectionState.fromMap (Map map) :
    this.conn      = new ClientConnection.fromMap (map[Key.state]),
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}