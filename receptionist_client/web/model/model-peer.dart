part of model;

class PeerState  {

  static final UNKNOWN      = new PeerState('Unknown');
  static final REGISTERED   = new PeerState('Registered');
  static final UNREGISTERED = new PeerState('Unregistered');
  
  String _name;
  
  PeerState (this._name);
  
  @override
  operator == (PeerState other) => this._name.toLowerCase() == other._name.toLowerCase();
  
  @override
  int get hashCode => this._name.hashCode;
  
  @override
  String toString () => this._name;
}

class Peer {
  
  static const String className = "${libraryName}.Peer";

  String         get ID   => this._cachedData['userid'];
  int            expires  =  null;
  PeerState _currentState =  PeerState.UNKNOWN;
  Map _cachedData         =  {};

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
    this._cachedData = map;
  }
  
  void update (Peer newPeer) {
    assert (this.ID == newPeer.ID);
    
    this.expires     = newPeer.expires;
    this._cachedData = newPeer._cachedData;
    this.state       = newPeer.state;
  }
  
  /**
   * Serialization function.
   */
  Map toJson() =>  this._cachedData;
  
  /**
   * Two peers are considered equal, if their ID's are.
   */
  @override
  bool operator == (Peer other) => this.ID == other.ID;
  
  /**
   * See the equals operator definition.
   */
  @override
  int get hashCode => this.ID.hashCode;
  
  /**
   * String representation of the peer.
   * 
   * Returns string with the format "ID - status".
   */
  @override
  String toString () => '${this.ID} - ${this.state}.'; 
  
}