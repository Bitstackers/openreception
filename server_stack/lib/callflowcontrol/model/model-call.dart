part of callflowcontrol.model;

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


class Call extends ORModel.Call {

  @override
  static final Logger log = new Logger('${libraryName}.Call');

  @override
  bool     _locked     = false;
  @override
  int      _assignedTo = ORModel.User.nullID;

  @override
  String get channel => this.ID;


  void set assignedTo(int userID) {
    log.finest('Assigning $this to $userID');
    this._assignedTo = userID;
  }

  @override
  int get assignedTo => this._assignedTo;

  @override
  bool get locked              => this._locked;
  @override
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

  @override
  void release() {
    log.finest('Releasing call assigned to: ${this.assignedTo}');

    if (this.assignedTo != ORModel.User.nullID) {
      //UserStatusList.instance.getOrCreate (this.assignedTo).callsHandled++;
      UserStatusList.instance.update(this.assignedTo, ORModel.UserState.WrappingUp);
    }

    this.assignedTo = ORModel.User.nullID;
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
     "b_leg"           : (this.b_Leg != null ? this.b_Leg : null),
     "locked"          : this.locked,
     "inbound"         : this.inbound,
     "is_call"         : true,
     "destination"     : this.destination,
     "caller_id"       : this.callerID,
     "greeting_played" : this.greetingPlayed,
     "reception_id"    : this.receptionID,
     "assigned_to"     : this.assignedTo,
     "channel"         : this.channel,
     "arrival_time"    : Util.dateTimeToUnixTimestamp (this.arrived)};

   Future park (ORModel.User user) {
     return Controller.PBX.park (this, user);
   }

  void changeState (String newState) {

    final String lastState = this.state;
    this.state = newState;

    log.finest('UUID: ${this.ID}: uid:${this.assignedTo} ${lastState} => ${newState}');

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
          Notification.broadcast(ClientNotification.callHangup (this));
        break;

      case (CallState.Speaking):
        Notification.broadcast(ClientNotification.callPickup (this));
        break;

      case (CallState.Transferred):
        Notification.broadcast(ClientNotification.callTransfer (this));
        break;

      case  (CallState.Ringing):
        Notification.broadcast(ClientNotification.callState (this));
        break;

      case (CallState.Transferring):
         break;

      default:
        log.severe('Changing call ${this} to Unkown state!');
      break;

    }
  }
}