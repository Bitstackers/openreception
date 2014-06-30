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
  static final int    noUser     = SharedModel.User.nullID;
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
      Service.Notification.broadcast(ClientNotification.callLock(this),
                                     config.notificationServer, config.serverToken);
    }else {
      Service.Notification.broadcast(ClientNotification.callUnlock(this),
                                     config.notificationServer, config.serverToken);
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

  void assignTo (SharedModel.User user) {
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

     
   void park (SharedModel.User user) {
    Controller.PBX.park (this, user);    
   }
     
  void changeState (String newState) {

    const String context   = '${className}.changeState';
    final String lastState = this.state;

    this.state = newState;

    logger.debugContext('UUID: ${this.ID}: ${lastState} => ${newState}',context);

    if (lastState == CallState.Queued) {
      Service.Notification.broadcast(ClientNotification.queueLeave (this),
                                     config.notificationServer, config.serverToken);
    } else if (lastState == CallState.Parked) {
      Service.Notification.broadcast(ClientNotification.callUnpark (this),
                                     config.notificationServer, config.serverToken);
    }

    switch (newState) {
      case (CallState.Created):
        Service.Notification.broadcast(ClientNotification.callOffer (this),
                                       config.notificationServer, config.serverToken);
        break;

      case (CallState.Parked):
        Service.Notification.broadcast(ClientNotification.callPark (this),
                                       config.notificationServer, config.serverToken);
        break;

      case (CallState.Unparked):
        Service.Notification.broadcast(ClientNotification.callUnpark (this),
                                       config.notificationServer, config.serverToken);
        break;

      case (CallState.Queued):
        Service.Notification.broadcast(ClientNotification.queueJoin (this),
                                       config.notificationServer, config.serverToken);
        break;

      case (CallState.Hungup):
        if (this.isCall) {
          Service.Notification.broadcast(ClientNotification.callHangup (this),
                                         config.notificationServer, config.serverToken);
        }
        //TODO: Call_List.Remove (ID => Obj.ID);
        break;

      case (CallState.Speaking):
        if (this.isCall) {
          Service.Notification.broadcast(ClientNotification.callPickup (this),
                                         config.notificationServer, config.serverToken);
        }
        break;

      case (CallState.Transferred):
        Service.Notification.broadcast(ClientNotification.callTransfer (this),
                                       config.notificationServer, config.serverToken);
        break;

      case  (CallState.Ringing):
        if (lastState != CallState.Ringing) {
          Service.Notification.broadcast(ClientNotification.callPickup (this),
                                         config.notificationServer, config.serverToken);
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