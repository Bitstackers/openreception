part of callflowcontrol.model;

class NotFound implements Exception {

  final String message;
  const NotFound([this.message = ""]);

  String toString() => "NotFound: $message";
}

class Forbidden implements Exception {

  final String message;
  const Forbidden([this.message = ""]);

  String toString() => "Forbidden: $message";
}

class CallList extends IterableBase<Call> {

  static const String className = '${libraryName}.CallList';

  Map<String, Call> _map = new Map<String, Call>();

  Iterator get iterator => this._map.values.iterator;

  static CallList instance = new CallList();

  List toJson() => this.toList(growable: false);

  void subscribe(Stream<ESL.Event> eventStream) {
    eventStream.listen(_handleEvent);
  }

  List<Call> callsOf(int userID) =>
      this.where((Call call) => call.assignedTo == userID).toList();

  Call get(String callID) {
    if (this._map.containsKey(callID)) {
      return this._map[callID];
    } else {
      throw new NotFound(callID);
    }
  }

  void remove (String callID) {
    if (this._map.containsKey(callID)) {
      this._map.remove(callID);
    } else {
      throw new NotFound(callID);
    }
  }

  Call requestCall(user) =>
    //TODO: Implement a real algorithm for selecting calls.
    this.firstWhere((Call call) => call.assignedTo == Call.noUser && !call.locked, orElse: () => throw new NotFound ("No calls available"));

  Call requestSpecificCall(String callID, SharedModel.User user )  {
    const String context = '${className}.requestSpecificCall';

    Call call = this.get(callID);

    if (![user.ID, Call.noUser].contains(call.assignedTo)) {
      logger.errorContext('Call ${callID} already assigned to ${call.assignedTo}', context);
      throw new Forbidden(callID);
    } else if (call.locked) {
      logger.debugContext('Requested locked call $callID', context);
      throw new NotFound(callID);
    }

    return call;
  }

  void _handleBridge(ESL.Packet packet) {
    const String context = '${className}._handleBridge';

    final Call aLeg = this.get(packet.field('Bridge-A-Unique-ID'));
    final Call bLeg = this.get(packet.field('Bridge-B-Unique-ID'));

    logger.debugContext('Bridging ${aLeg.toJson()} and ${bLeg.toJson()}', context);

    //  Inherit the context from the other channel.
    if (aLeg.receptionID == Call.nullReceptionID) {
      /// Inherit fields from b-Leg.
      aLeg..receptionID = bLeg.receptionID
          ..contactID   = bLeg.contactID
          ..assignedTo  = bLeg.assignedTo;
    } else if (bLeg.receptionID == Call.nullReceptionID) {
      /// Inherit fields from a-Leg.
      bLeg..receptionID = aLeg.receptionID
          ..contactID   = aLeg.contactID
          ..assignedTo  = aLeg.assignedTo;
    }

    aLeg.link(bLeg);

    OriginationRequest.confirm(aLeg);
    OriginationRequest.confirm(bLeg);

    if (TransferRequest.contains (aLeg.ID, bLeg.ID)) {
      TransferRequest.confirm (aLeg.ID, bLeg.ID);
       aLeg.changeState (CallState.Transferred);
       bLeg.changeState (CallState.Transferred);
    }

    aLeg.changeState (CallState.Speaking);
    bLeg.changeState (CallState.Speaking);
  }

  void _handleChannelState (ESL.Packet packet) {
    const String context = '${className}._handleChannelState';

     if (packet.field('Channel-Call-State') == 'RINGING') {
       Call call = this.get(packet.uniqueID);
       if (call.b_Leg != null && (OriginationRequest.contains (call) || OriginationRequest.contains(call.b_Leg))) {
         if (call.receptionID == Call.nullReceptionID) {
           /// Inherit fields from b-Leg.
           call..receptionID = call.b_Leg.receptionID
               ..contactID   = call.b_Leg.contactID
               ..assignedTo  = call.b_Leg.assignedTo;
         }

         call.changeState(CallState.Ringing);
         logger.debugContext ('${call.ID} is part of origination request '
                              'and other_leg is ${call.b_Leg}', context);
       }
     }
  }

  void _handleChannelDestroy (ESL.Packet packet) {
    const String context = '${className}._handleChannelDestroy';
    try {
      /// Remove the call assignment from user->call and call->user
      this.get(packet.uniqueID).release();
      this.get(packet.uniqueID).changeState(CallState.Hungup);

      logger.debugContext('Hanging up ${packet.uniqueID}', context);
      this.remove(packet.uniqueID);

    } catch (error) {
      if (error is NotFound) {
        logger.errorContext('Tried to hang up non-existing call ${packet.uniqueID}.'
                            'Call list may be inconsistent - consider reloading.', context);
      } else {
        logger.errorContext(error, context);
      }
    }
  }


  void _handleCustom (ESL.Packet packet) {
    const String context = '${className}._handleCustom';

    switch (packet.eventSubclass) {
      case ("AdaHeads::pre-queue-enter"):
        this.get(packet.uniqueID)
            ..receptionID =
              packet.contentAsMap.containsKey('variable_reception_id')
                        ? int.parse(packet.field('variable_reception_id'))
                        : 0
            ..isCall = true
            ..changeState(CallState.Created);

        break;
      case ("AdaHeads::outbound-call"):
           logger.debugContext ('Outbound call: ${packet.uniqueID}', context);
           OriginationRequest.create (packet.uniqueID);

          this.get(packet.uniqueID)
               ..receptionID = int.parse(packet.field('variable_reception_id'))
               ..contactID   = int.parse(packet.field('variable_contact_id'))
               ..assignedTo  = int.parse(packet.field('variable_owner'));

           break;
      case ('AdaHeads::pre-queue-leave'):
        logger.debugContext('Locking ${packet.uniqueID}', context);
        CallList.instance.get (packet.uniqueID)
          ..changeState (CallState.Transferring)
          ..locked = true;
        break;

      case ('AdaHeads::wait-queue-enter'):
        logger.debugContext('Unlocking ${packet.uniqueID}', context);
        CallList.instance.get (packet.uniqueID)
          ..locked = false
          ..greetingPlayed = true //TODO: Change this into a packet.variable.get ('greetingPlayed')
          ..changeState (CallState.Queued);
        break;

      case ('AdaHeads::parking-lot-enter'):
        CallList.instance.get (packet.uniqueID)
          ..changeState (CallState.Parked);
        break;

      case ('AdaHeads::parking-lot-leave'):
        CallList.instance.get (packet.uniqueID)
          ..changeState (CallState.Transferring);
        break;
    }
  }


  void _handleEvent(ESL.Event event) {
    const String context = '${className}._handleEvent';

    void dispatch () {
      switch (event.eventName) {

        case ('CHANNEL_BRIDGE'):
          this._handleBridge(event);
          break;

        case ('CHANNEL_STATE'):
          this._handleChannelState(event);
          break;

        case ('CHANNEL_CREATE'):
          this._createCall(event);
          break;

        case ('CHANNEL_DESTROY'):
          this._handleChannelDestroy(event);
          break;

        case ("CUSTOM"):
          this._handleCustom(event);
          break;
      }
    }


    //print (packet.eventName + '::' + packet.eventSubclass);
  try {
    dispatch();
  } catch (error, stackTrace) {
    logger.errorContext('$error : $stackTrace', context);
    }
  }

  Call _createCall(ESL.Packet packet) {
    const String context = '${className}._createCall';
    logger.debugContext('Creating new channel ${packet.uniqueID}', context);
    Call createdCall = new Call()
        ..ID = packet.uniqueID
        ..isCall = false
        ..inbound = (packet.field('Call-Direction') == 'inbound' ? true : false)
        ..callerID = packet.field('Caller-Caller-ID-Number')
        ..destination = packet.field('Caller-Destination-Number');

    this._map[packet.uniqueID] = createdCall;

    return createdCall;
  }
}
