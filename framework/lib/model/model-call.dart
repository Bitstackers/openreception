part of openreception.model;

/**
 * Enumeration type for call related JSON keys.
 */
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

/**
 * Enumeration type for call states.
 */
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

/**
 *
 */
class Call {

  static const String    className       = '${libraryName}.Call';
  static final Logger    _log            = new Logger (Call.className);

  static final Call      noCall          = new Call.empty(noID);
  static final String    noID            = '';

  final Bus<String>          _callState  = new Bus<String>();
  final Bus<Event.CallEvent> _eventBus   = new Bus<Event.CallEvent>();

  DateTime               arrived         = new DateTime.now();
  int                    assignedTo      = User.noID;
  String                 b_Leg           = null;
  String                 callerID        = null;
  int                    contactID       = null;
  String                 destination     = null;
  bool                   greetingPlayed  = false;
  String                 _ID             = noID;
  bool                   inbound         = null;
  bool                   _locked         = false;
  int                    receptionID     = Reception.noID;
  String                 _state          = CallState.Unknown;

  /**
   * Constructor.
   */
  Call.empty(this._ID);

  /**
   * Constructor.
   */
  Call.fromMap(map) {
    _ID                 = map[CallJsonKey.ID];
    _state              = map[CallJsonKey.state];
    this.b_Leg          = map[CallJsonKey.bLeg];
    this._locked        = map[CallJsonKey.locked];
    this.inbound        = map[CallJsonKey.inbound];
    this.destination    = map[CallJsonKey.destination];
    this.callerID       = map[CallJsonKey.callerID];
    this.greetingPlayed = map[CallJsonKey.greetingPlayed];
    this.receptionID    = map[CallJsonKey.receptionID];
    this.assignedTo     = map[CallJsonKey.assignedTo];
    this.arrived        = Util.unixTimestampToDateTime (map[CallJsonKey.arrivalTime]);
  }

  /**
   *
   */
  @override
  operator == (Call other) => _ID == other._ID;

  /**
   *
   */
  void assignTo(User user) {
    assignedTo = user.ID;
  }

  /**
   *
   */
  Stream<String> get callState => _callState.stream;

  /**
   *
   */
  void changeState(String newState) {
    final String lastState = _state;

    _state = newState;

    _log.finest('UUID: ${_ID}: ${lastState} => ${newState}');

    if(lastState == CallState.Queued) {
      notifyEvent(new Event.QueueLeave(this));
    } else if(lastState == CallState.Parked) {
      notifyEvent(new Event.CallUnpark(this));
    }

    switch(newState) {
      case(CallState.Created):
        notifyEvent(new Event.CallOffer(this));
        break;

      case(CallState.Parked):
        notifyEvent(new Event.CallPark(this));
        break;

      case(CallState.Unparked):
        notifyEvent(new Event.CallUnpark(this));
        break;

      case(CallState.Queued):
        notifyEvent(new Event.QueueJoin(this));
        break;

      case(CallState.Hungup):
        notifyEvent (new Event.CallHangup(this));
        break;

      case(CallState.Speaking):
        notifyEvent(new Event.CallPickup(this));
        break;

      case(CallState.Transferred):
        notifyEvent(new Event.CallTransfer(this));
        break;

      case(CallState.Ringing):
        notifyEvent(new Event.CallStateChanged(this));
        break;

      case(CallState.Transferring):
         break;

      default:
        _log.severe('Changing call ${this} to Unkown state!');
      break;
    }
  }

  /**
   * Note: The channel is a unique identifier.
   *   Remember to change, if ID changes.
   */
  String get channel => _ID;

  /**
   * The Unique identification of the call
   */
  String get ID => _ID;

  /**
   *
   */
  String get state  => _state;

  /**
   *
   */
  set state(String newState) {
    _state = newState;
    _callState.fire(newState);
  }

  /**
   *
   */
  Stream<Event.CallEvent> get event => _eventBus.stream;

  /**
   *
   */
  @override
  int get hashCode => _ID.hashCode;

  /**
   *
   */
  bool get isActive => this != noCall;

  /**
   *
   */
  void link(Call other) {
    if(locked) locked = false;

    b_Leg  = other._ID;
    other.b_Leg = _ID;
  }

  /**
   *
   */
  bool get locked => _locked;

  /**
   *
   */
  void set locked(bool lock)   {
    _locked = lock;

    if(lock) {
      notifyEvent(new Event.CallLock((this)));
    }else {
      notifyEvent(new Event.CallUnlock(this));
    }
  }

  /**
   *
   */
  void notifyEvent(Event.Event event) => _eventBus.fire(event);

  /**
   *
   */
  void release() {
    assignedTo = User.noID;
  }

  /**
   * String version of [Call] for debug/log purposes.
   */
  @override
  String toString() =>
      this == noCall
      ? 'no Call'
      : 'Call ID: ${_ID}, state: ${_state}, destination: ${destination}';

  /**
   *
   */
  Map toJson() => {CallJsonKey.ID             : _ID,
                   CallJsonKey.state          : _state,
                   CallJsonKey.bLeg           : b_Leg,
                   CallJsonKey.locked         : locked,
                   CallJsonKey.inbound        : inbound,
                   CallJsonKey.destination    : destination,
                   CallJsonKey.callerID       : callerID,
                   CallJsonKey.greetingPlayed : greetingPlayed,
                   CallJsonKey.receptionID    : receptionID,
                   CallJsonKey.assignedTo     : assignedTo,
                   CallJsonKey.channel        : channel,
                   CallJsonKey.arrivalTime    : Util.dateTimeToUnixTimestamp(arrived)};

  /**
   *
   */
  static void validateID(String callID) {
    if(callID == null || callID.isEmpty) {
      throw new FormatException('Invalid Call ID: ${callID}');
    }
  }
}
