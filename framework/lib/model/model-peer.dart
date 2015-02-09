part of openreception.model;

abstract class PeerJSONKey {
  static const ID         = 'id';
  static const REGISTERED = 'registered';
  static const CHAN_COUNT = 'activeChannels';
}

class Peer {
  final String ID;
  final int    channelCount;

  bool registered;

  Peer (this.ID, this.channelCount);

  Map get asMap => {
    PeerJSONKey.ID         : this.ID,
    PeerJSONKey.REGISTERED : this.registered,
    PeerJSONKey.CHAN_COUNT : this.channelCount
  };

  Peer.fromMap (Map map) :
    this.ID           = map[PeerJSONKey.ID],
    this.registered   = map[PeerJSONKey.REGISTERED],
    this.channelCount = map[PeerJSONKey.CHAN_COUNT];

  Map toJson() => this.asMap;

  @override
  String toString() => '${this.ID}, registered:${this.registered}';

}