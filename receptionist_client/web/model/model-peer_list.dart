part of model;

class PeerList extends IterableBase<Peer> {

  static const String className = "${libraryName}.PeerList";

  static final EventType reload = new EventType();
  static final EventType<Peer> stateChange = new EventType<Peer>();

  EventBus _bus = event.bus; // Just hook into the global event bus.
  EventBus get events => _bus;

  EventBus _eventStream = event.bus;

  /* Singleton instance - for quick and easy reference. */
  static PeerList _instance = new PeerList();
  static PeerList get instance => _instance;
  static set instance(PeerList newList) => _instance = newList;

  /* A set would have been a better fit here, but it makes the code
   * read terribly. */
  Map<String, Peer> _map = new Map<String, Peer>();

  /**
   * Iterator. This merely forwards the values from within the internal map.
   * We are not interested in the keys (Peer ID) as they are already stored inside
   * the Peer Object.
   */
  Iterator<Peer> get iterator => this._map.values.iterator;

  /**
   * Default constructor.
   */
  PeerList();
  
  void update(Peer peer) {
    if (this._map.containsKey(peer.ID)) {
      this._map[peer.ID].update(peer);
    } else {
      this._map[peer.ID] = peer;
    }
  }
  
  /**
   * TODO
   */
  PeerList.fromList (List<Map> peerMaps) {
    peerMaps.forEach((Map peerMap) {
      this.update(new Peer.fromMap(peerMap));
    });
  }
  
  /**
   * 
   */
  Future<PeerList> reloadFromServer() {
    return Service.Peer.list().then ((PeerList peerList){
      this._map = peerList._map;
      
      return this;
    });
  }
}
