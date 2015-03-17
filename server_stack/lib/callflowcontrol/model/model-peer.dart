part of callflowcontrol.model;


//TODO: test api command: sofia_presence_data list|status|rpid|user_agent [profile/]<user>@domain
class Peer extends ESL.Peer {

  Peer.fromESLPeer(ESL.Peer eslPeer) {
    this.ID      = eslPeer.ID;
    this.contact = eslPeer.contact;
  }

  Map get asMap =>
      {
          'id'         : this.ID,
          'registered' : this.registered,
          'activeChannels' : ChannelList.instance.activeChannelCount(this.ID)
      };

  @override
  Map toJson() => this.asMap;
}