part of openreception.event;

class ChannelState implements Event {
  final DateTime timestamp;
  final String   eventName = Key.channelState;
  final String   channelID;

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.channel (this);

  ChannelState(String channelID) :
      this.channelID = channelID,
      this.timestamp = new DateTime.now();

  ChannelState.fromMap (Map map) :
    this.channelID = map[Key.channel][Key.ID],
    this.timestamp = Util.unixTimestampToDateTime (map[Key.timestamp]);
}


