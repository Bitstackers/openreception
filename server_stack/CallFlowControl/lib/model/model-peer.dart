part of callflowcontrol.model;

class Peer extends ESL.Peer {

  Peer.fromESLPeer(ESL.Peer eslPeer) {
    this.ID      = eslPeer.ID;
    this.contact = eslPeer.contact;
  }

  Map get asMap =>
      {
          'id'         : this.ID,
          'registered' : this.registered
      };

  @override
  Map toJson() => this.asMap;
}