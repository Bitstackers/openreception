part of model;

class PeerState  {

  static final UNKNOWN      = new PeerState('Unknown');
  static final REGISTERED   = new PeerState('Registered');
  static final UNREGISTERED = new PeerState('Unregistered');
  
  final String name;
  
  PeerState (this.name);
}

class Peer {
  
  static const String className = "${libraryName}.Peer";

  String              ID  = null;
  int            expires  = null;
  PeerState _currentState = PeerState.UNKNOWN;
  Map _cachedData         = {};

  static final EventType<PeerState> stateChange = new EventType<PeerState>();

  EventBus _eventStream = event.bus; // Just hook into the global event bus.
  EventBus get events   => _eventStream;

  PeerState get state => _currentState;
  void set state (PeerState newState) {
    if (this._currentState != newState) {
      this._currentState = newState;
      this.events.fire(stateChange, newState);
    }
  }

  Peer.fromMap(Map map) {
    this._currentState = (map['registered'] ? PeerState.REGISTERED : PeerState.UNREGISTERED);
    this.ID = map['userid'];
    this._cachedData = map;
  }
  
  /**
   * 
   */
  @override
  String toString () {
    return this.toMap().toString();
  }

  void update (Peer newPeer) {
    assert (this.ID == newPeer.ID);
    
    this.expires     = newPeer.expires;
    this._cachedData = newPeer._cachedData;
    this.state       = newPeer.state;
  }
  
  Map toMap() {
    this._cachedData['peer_id'] = this.ID;
    return this._cachedData;
  }
  
  Map toJSON() {
    return this.toMap();
  }

  bool operator ==(Call other) {
    return this.ID == other.ID;
  }

  int get hashCode {
    return this.ID.hashCode;
  }
  
}