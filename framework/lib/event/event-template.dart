part of openreception.event;

abstract class EventTemplate {
  static Map _rootElement(Event event) => {
    Key.event     : event.eventName,
    Key.timestamp : Util.dateTimeToUnixTimestamp (event.timestamp)
  };

  static Map call(CallEvent event) =>
      _rootElement(event)..addAll( {Key.call : event.call});

  static Map peer(PeerState event) =>
      _rootElement(event)..addAll( {Key.peer : event.peer});

  static Map userState(UserState event) =>
      _rootElement(event)..addAll(event.status.asMap);

  static Map channel(ChannelState event) =>
      _rootElement(event)..addAll(
           {Key.channel :
             {Key.ID : event.channelID}});

  static Map connection(ClientConnectionState event) =>
      _rootElement(event)..addAll({Key.state : event.conn});
}

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