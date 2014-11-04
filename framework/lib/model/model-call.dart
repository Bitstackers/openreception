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


class Call {

  static const String className  = '${libraryName}.Call';

  static final Logger log        = new Logger (Call.className);

  static final String nullCallID = null;
  static final int    noUser     = User.nullID;
  static const int    nullReceptionID = 0;

  final StreamController<Event> _streamController = new StreamController.broadcast();

  Stream get event => this._streamController.stream;

  String   ID              = nullCallID;
  Call     b_Leg           = null;
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
      notifyEvent(new CallLock((this)));
    }else {
      notifyEvent(new CallUnlock(this));
    }
  }

  Call.fromMap (map) {
    throw new StateError ('Not implemented!');
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

  void notifyEvent (Event event) => this._streamController.add(event);

  void assignTo (User user) {
    this.assignedTo = user.ID;
  }

  void release() {
    this.assignedTo = noUser;
  }

  void link (Call other) {
    this.locked = false;

    this.b_Leg  = other;
    other.b_Leg = this;
  }

   @override
  String toString () => this.ID;

   Map toJson () => {
     'id'              : this.ID,
     "state"           : this.state,
     "b_leg"           : (this.b_Leg != null ? this.b_Leg.ID : null),
     "locked"          : this.locked,
     "inbound"         : this.inbound,
     "is_call"         : this.isCall,
     "destination"     : this.destination,
     "caller_id"       : this.callerID,
     "greeting_played" : this.greetingPlayed,
     "reception_id"    : this.receptionID,
     "assigned_to"     : this.assignedTo,
     "channel"         : this.channel,
     "arrival_time"    : dateTimeToUnixTimestamp (this.arrived)};

  void changeState (String newState) {

    const String context   = '${className}.changeState';
    final String lastState = this.state;

    this.state = newState;

    log.finest ('UUID: ${this.ID}: ${lastState} => ${newState}');

    if (lastState == CallState.Queued) {
      notifyEvent (new QueueLeave(this));
    } else if (lastState == CallState.Parked) {
      notifyEvent (new CallUnpark(this));
    }

    switch (newState) {
      case (CallState.Created):
        notifyEvent(new CallOffer(this));
        break;

      case (CallState.Parked):
        notifyEvent(new CallPark(this));
        break;

      case (CallState.Unparked):
        notifyEvent(new CallUnpark(this));
        break;

      case (CallState.Queued):
        notifyEvent(new QueueJoin(this));
        break;

      case (CallState.Hungup):
        notifyEvent (new CallHangup(this));
        break;

      case (CallState.Speaking):
        notifyEvent(new CallPickup(this));
        break;

      case (CallState.Transferred):
        notifyEvent(new CallTransfer(this));
        break;

      case  (CallState.Ringing):
        notifyEvent(new CallStateChanged(this));
        break;

      case (CallState.Transferring):
         break;

      default:
        log.severe ('Changing call ${this} to Unkown state!');
      break;

    }
  }
}