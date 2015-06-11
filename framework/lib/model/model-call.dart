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
  DateTime               arrived        = new DateTime.now();
  int                    assignedTo     = User.noID;
  String                 bLeg           = null;
  String                 callerID       = null;
  final Bus<String>      _callState     = new Bus<String>();
  int                    contactID      = null;
  String                 _currentState  = CallState.Unknown;
  String                 destination    = null;
  final Bus<Event.Event> _eventBus      = new Bus<Event.Event>();
  bool                   greetingPlayed = false;
  String                 _ID            = null;
  bool                   inbound        = null;
  bool                   isCall         = null;
  bool                   _locked        = false;
  final Logger           _log           = new Logger('${libraryName}.Call');
  static final Call      noCall         = new Call.empty();
  int                    receptionID    = null;
  String                 state          = CallState.Unknown;

  /**
   * Constructor.
   * TODO (KRC): Remove when no longer needed in ServerStack.
   */
  Call();

  /**
   * Constructor.
   */
  Call.empty();

  /**
   * Constructor.
   */
  Call.fromMap(map) {
    _ID            = map[CallJsonKey.ID];
    state          = map[CallJsonKey.state];
    bLeg           = map[CallJsonKey.bLeg];
    _locked        = map[CallJsonKey.locked];
    inbound        = map[CallJsonKey.inbound];
    isCall         = map[CallJsonKey.isCall];
    destination    = map[CallJsonKey.destination];
    callerID       = map[CallJsonKey.callerID];
    greetingPlayed = map[CallJsonKey.greetingPlayed];
    receptionID    = map[CallJsonKey.receptionID];
    assignedTo     = map[CallJsonKey.assignedTo];
    arrived        = Util.unixTimestampToDateTime (map[CallJsonKey.arrivalTime]);
  }

  /**
   *
   */
  @override
  operator == (Call other) => _ID == other.ID;

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
    final String lastState = state;

    state = newState;

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
   *
   */
  String get channel => ID; //The channel is a unique identifier. Remember to change, if ID changes.

  /**
   *
   */
  String get currentState  => _currentState;

  /**
   *
   */
  set currentState(String newState) {
    _currentState = newState;
    _callState.fire(newState);
  }

  /**
   *
   */
  Stream<Event.Event> get event => _eventBus.stream;

  /**
   *
   */
  @override
  int get hashCode => _ID.hashCode;

  /**
   *
   */
  String get ID => _ID;

  /**
   *
   */
  bool get isActive => this != noCall;

  /**
   *
   */
  void link(Call other) {
    locked = false;

    bLeg  = other.ID;
    other.bLeg = _ID;
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
      : 'Call ID: ${_ID}, state: ${state}, destination: ${destination}';

  /**
   *
   */
  Map toJson() => {CallJsonKey.ID             : _ID,
                   CallJsonKey.state          : state,
                   CallJsonKey.bLeg           : bLeg,
                   CallJsonKey.locked         : locked,
                   CallJsonKey.inbound        : inbound,
                   CallJsonKey.isCall         : isCall,
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
