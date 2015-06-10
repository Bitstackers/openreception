part of openreception.model;

abstract class CallState {

   static const String Unknown      = 'UNKNOWN';
   static const String Created      = 'CREATED';
   static const String Ringing      = 'RINGING';
   static const String Queued       = 'QUEUED';
   static const String Unparked     = 'UNPARKED';
   static const String Hungup       = 'HUNGUP';
   static const String Transferring = 'TRANSFERRING';
   static const String Transferred  = 'TRANSFERRED';
   static const String Speaking     = 'SPEAKING';
   static const String Parked       = 'PARKED';
}

abstract class CallJsonKey {
  static const String ID             = 'id';
  static const String state          = 'state';
  static const String bLeg           = 'b_leg';
  static const String locked         = 'locked';
  static const String inbound        = 'inbound';
  static const String isCall         = 'is_call';
  static const String destination    = 'destination';
  static const String callerID       = 'caller_id';
  static const String greetingPlayed = 'greeting_played';
  static const String receptionID    = 'reception_id';
  static const String assignedTo     = 'assigned_to';
  static const String channel        = 'channel';
  static const String arrivalTime    = 'arrival_time';
}

class Call {

  static const String className  = '${libraryName}.Call';

  static final Logger log        = new Logger (Call.className);

  static final String nullCallID = null;
  static final int    noUser     = User.noID;
  static const int    nullReceptionID = 0;
  static final Call noCall = new Call.empty();

  Bus<String> _callState = new Bus<String>();
  Stream<String> get callState => _callState.stream;

  static Call _activeCall = new Call.empty();
  static Call get activeCall => _activeCall;

  static Bus<Call> _activeCallChanged = new Bus<Call>();
  static Stream<Call> get activeCallChanged => _activeCallChanged.stream;

  static set activeCall(Call newCall) {
    _activeCall = newCall;
    _activeCallChanged.fire(_activeCall);
    log.finest('Changing active call to ${_activeCall.ID}:');
  }

 bool get isActive => this != noCall;

  String _currentState = CallState.Unknown;
  String get currentState  => _currentState;

  set currentState (String newState) {
    this._currentState = newState;
    this._callState.fire(newState);
  }


  final StreamController<Event.Event> _streamController = new StreamController.broadcast();

  Stream get event => this._streamController.stream;

  String   ID              = nullCallID;
  String   b_Leg           = null;
  String   get channel     => this.ID; //The channel is a unique identifier. Remember to change, if ID changes.
  String   state           = CallState.Unknown;
  String   destination     = null;
  String   callerID        = null;
  bool     _isCall         = null;
  bool     greetingPlayed  = false;
  bool     _locked         = false;
  bool     inbound         = null;
  int      receptionID     = nullReceptionID;
  int      assignedTo      = noUser;
  int      contactID       = null;
  DateTime arrived         = new DateTime.now();


  bool get isCall              => this._isCall;
  void set isCall (bool value)   {this._isCall = value;}
  bool get locked              => this._locked;

  void set locked (bool lock)   {
    this._locked = lock;

    if (lock) {
      notifyEvent(new Event.CallLock((this)));
    }else {
      notifyEvent(new Event.CallUnlock(this));
    }
  }

  /**
   * TODO: Remove when no longer needed in ServerStack.
   */
  Call();

  Call.empty ();

  Call.fromMap (map) {
    this.ID = map[CallJsonKey.ID];
    this.state = map[CallJsonKey.state];
    this.b_Leg = map[CallJsonKey.bLeg];
    this._locked = map[CallJsonKey.locked];
    this.inbound = map[CallJsonKey.inbound];
    this._isCall = map[CallJsonKey.isCall];
    this.destination = map[CallJsonKey.destination];
    this.callerID = map[CallJsonKey.callerID];
    this.greetingPlayed = map[CallJsonKey.greetingPlayed];
    this.receptionID = map[CallJsonKey.receptionID];
    this.assignedTo = map[CallJsonKey.assignedTo];
    this.arrived = Util.unixTimestampToDateTime (map[CallJsonKey.arrivalTime]);
  }

  @override
  operator == (Call other) => this.ID == other.ID;

  @override
  int get hashCode => this.ID.hashCode;

  static void validateID (String callID) {
    if (callID == null || callID == nullCallID || callID.isEmpty) {
      throw new FormatException('Invalid Call ID: ${callID}');
    }
  }

  void notifyEvent (Event.Event event) => this._streamController.add(event);

  void assignTo (User user) {
    this.assignedTo = user.ID;
  }

  void release() {
    this.assignedTo = noUser;
  }

  void link (Call other) {
    this.locked = false;

    this.b_Leg  = other.ID;
    other.b_Leg = this.ID;
  }

  /**
   * [Call] as String, for debug/log purposes.
   */
  @override
  String toString() => this == noCall
                       ? 'no Call'
                       : 'Call ID:${this.ID}, state:${this.state}, '
                         'destination:${this.destination}';

   Map toJson () => {
     CallJsonKey.ID             : this.ID,
     CallJsonKey.state          : this.state,
     CallJsonKey.bLeg           : this.b_Leg,
     CallJsonKey.locked         : this.locked,
     CallJsonKey.inbound        : this.inbound,
     CallJsonKey.isCall         : this.isCall,
     CallJsonKey.destination    : this.destination,
     CallJsonKey.callerID       : this.callerID,
     CallJsonKey.greetingPlayed : this.greetingPlayed,
     CallJsonKey.receptionID    : this.receptionID,
     CallJsonKey.assignedTo     : this.assignedTo,
     CallJsonKey.channel        : this.channel,
     CallJsonKey.arrivalTime    : Util.dateTimeToUnixTimestamp (this.arrived)};

  void changeState (String newState) {

    final String lastState = this.state;

    this.state = newState;

    log.finest ('UUID: ${this.ID}: ${lastState} => ${newState}');

    if (lastState == CallState.Queued) {
      notifyEvent (new Event.QueueLeave(this));
    } else if (lastState == CallState.Parked) {
      notifyEvent (new Event.CallUnpark(this));
    }

    switch (newState) {
      case (CallState.Created):
        notifyEvent(new Event.CallOffer(this));
        break;

      case (CallState.Parked):
        notifyEvent(new Event.CallPark(this));
        break;

      case (CallState.Unparked):
        notifyEvent(new Event.CallUnpark(this));
        break;

      case (CallState.Queued):
        notifyEvent(new Event.QueueJoin(this));
        break;

      case (CallState.Hungup):
        notifyEvent (new Event.CallHangup(this));
        break;

      case (CallState.Speaking):
        notifyEvent(new Event.CallPickup(this));
        break;

      case (CallState.Transferred):
        notifyEvent(new Event.CallTransfer(this));
        break;

      case  (CallState.Ringing):
        notifyEvent(new Event.CallStateChanged(this));
        break;

      case (CallState.Transferring):
         break;

      default:
        log.severe ('Changing call ${this} to Unkown state!');
      break;

    }
  }
}