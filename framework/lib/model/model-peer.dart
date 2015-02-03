part of openreception.model;

abstract class PeerJSONKey {
  static const ID         = 'id';
  static const REGISTERED = 'registered';
}

class Peer {
  final String ID;

  bool registered;

  Peer (this.ID);

  Map get asMap => {
    PeerJSONKey.ID         : this.ID,
    PeerJSONKey.REGISTERED : this.registered
  };

  Peer.fromMap (Map map) :
    this.ID         = map[PeerJSONKey.ID],
    this.registered = map[PeerJSONKey.REGISTERED];

  Map toJson() => this.asMap;

  @override
  String toString() => '${this.ID}, registered:${this.registered}';

}