part of callflowcontrol.model;

abstract class CallState {

   static const String Unknown = 'UNKNOWN';
   static const String Created = 'CREATED';
   static const String Ringing = 'RINGING';
   static const String Queued  = 'QUEUED';
   static const String Unparked = 'UNPARKED';
   static const String Hungup  = 'HUNGUP';
   static const String Transferring = 'TRANSFERRING';
   static const String Transferred = 'TRANSFERRED';
   static const String Speaking = 'SPEAKING';
   static const String Parked = 'PARKED';
}


class Call {

  static const String className  = '${libraryName}.Call';

  static final String nullCallID = null;
  static final int    noUser     = ORModel.User.nullID;
  static const int    nullReceptionID = 0;

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
      Notification.broadcast(ClientNotification.callLock(this));
    }else {
      Notification.broadcast(ClientNotification.callUnlock(this));
    }
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

  void assignTo (ORModel.User user) {
    this.assignedTo = user.ID;
  }

  void release() {
    logger.debugContext('Releasing call assigned to: ${this.assignedTo}', 'RELEASE');

    if (this.assignedTo != noUser) {
      UserStatusList.instance.get (this.assignedTo).callsHandled++;
      UserStatusList.instance.update(this.assignedTo, ORModel.UserState.WrappingUp);
    }

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


   Future park (ORModel.User user) {
     return Controller.PBX.park (this, user);
   }

  void changeState (String newState) {

    const String context   = '${className}.changeState';
    final String lastState = this.state;

    this.state = newState;

    logger.debugContext('UUID: ${this.ID}: ${lastState} => ${newState}',context);

    if (lastState == CallState.Queued) {
      Notification.broadcast(ClientNotification.queueLeave (this));
    } else if (lastState == CallState.Parked) {
      Notification.broadcast(ClientNotification.callUnpark (this));
    }

    switch (newState) {
      case (CallState.Created):
        Notification.broadcast(ClientNotification.callOffer (this));
        break;

      case (CallState.Parked):
        Notification.broadcast(ClientNotification.callPark (this));
        break;

      case (CallState.Unparked):
        Notification.broadcast(ClientNotification.callUnpark (this));
        break;

      case (CallState.Queued):
        Notification.broadcast(ClientNotification.queueJoin (this));
        break;

      case (CallState.Hungup):
        if (this.isCall) {
          Notification.broadcast(ClientNotification.callHangup (this));
        }
        //TODO: Call_List.Remove (ID => Obj.ID);
        break;

      case (CallState.Speaking):
        if (this.isCall) {
          Notification.broadcast(ClientNotification.callPickup (this));
        }
        break;

      case (CallState.Transferred):
        Notification.broadcast(ClientNotification.callTransfer (this));
        break;

      case  (CallState.Ringing):
        if (lastState != CallState.Ringing) {
          Notification.broadcast(ClientNotification.callPickup (this));
        }
        break;

      case (CallState.Transferring):
         break;

      default:
        logger.errorContext('Changing call ${this} to Unkown state!' , context);
      break;

    }
  }
}