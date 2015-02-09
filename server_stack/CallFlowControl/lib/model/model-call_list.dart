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

  bool containsID (String callID) => this._map.containsKey(callID);

  void subscribe(Stream<ESL.Event> eventStream) {
    eventStream.listen(_handleEvent);
  }

  void subscribeChannelEvents(Stream<ChannelEvent> eventStream) {
    eventStream.listen(_handleChannelsEvent);
  }

  void _handleChannelsEvent(ChannelEvent channelEvent) {
    const String context = '${className}._handleEvent';

    void handleCreate () {}
    void handleUpdate () {}


    void handleRemove () {}

    void dispatch () {
      switch (channelEvent.eventName) {

        case (ChannelEventName.CREATE):
          handleCreate ();
          break;

        case (ChannelEventName.UPDATE):
          handleUpdate();
          break;

        case (ChannelEventName.DESTROY):
          handleRemove();
          break;

        case (ChannelEventName.CREATE):
          break;

        default:
          throw new ArgumentError('Bad channel event name: ${channelEvent.eventName}');
      }
    }


  try {
    dispatch();
  } catch (error, stackTrace) {
    logger.errorContext('$error : $stackTrace', context);
    }
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

  Call requestSpecificCall(String callID, ORModel.User user )  {
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

  bool isCall (ESL.Channel channel) =>
      this.containsID (channel.UUID);


  void _handleBridge(ESL.Packet packet) {
    const String context = '${className}._handleBridge';


    final ESL.Channel aLeg = ChannelList.instance.get(packet.field('Bridge-A-Unique-ID'));
    final ESL.Channel bLeg = ChannelList.instance.get(packet.field('Bridge-B-Unique-ID'));

    logger.debugContext('Bridging channel ${aLeg} and channel ${bLeg}', context);

    if (isCall(aLeg) && isCall(bLeg)) {
      CallList.instance.get(aLeg.UUID).changeState (CallState.Transferred);
      CallList.instance.get(bLeg.UUID).changeState (CallState.Transferred);
    }

    else if (isCall(aLeg)) {
      CallList.instance.get(aLeg.UUID).changeState (CallState.Speaking);
    }

    else if (isCall(bLeg)) {
      CallList.instance.get(bLeg.UUID).changeState (CallState.Speaking);
    }

    // Local calls??
    else {
      logger.errorContext('Local calls are not supported!', context);
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
        this._createCall(packet);

        this.get(packet.uniqueID)
            ..receptionID =
              packet.contentAsMap.containsKey('variable_reception_id')
                        ? int.parse(packet.field('variable_reception_id'))
                        : 0
            ..changeState(CallState.Created);

        break;
//      case ("AdaHeads::outbound-call"):
//           logger.debugContext ('Outbound call: ${packet.uniqueID}', context);
//           OriginationRequest.create (packet.uniqueID);
//
//          this.get(packet.uniqueID)
//               ..receptionID = int.parse(packet.field('variable_reception_id'))
//               ..contactID   = int.parse(packet.field('variable_contact_id'))
//               ..assignedTo  = int.parse(packet.field('variable_owner'));
//
//           break;
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

//        case ('CHANNEL_STATE'):
//          this._handleChannelState(event);
//          break;

        /// OUtbound calls
        case ('CHANNEL_ORIGINATE'):
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


  try {
    dispatch();
  } catch (error, stackTrace) {
    logger.errorContext('$error : $stackTrace', context);
    }
  }

  /**
   * Some notes on call creation;
   *
   * We are using the PBX to spawn (originate channels) to the user phones
   * to establish a connection which we can then use to dial out or transfer
   * uuid's to.
   * These will, in their good right, spawn CHANNEL_ORIGINATE events which we
   * manually need to filter :-\
   * For now, the filter for origination is done by tagging the channels with a
   * variable ([Controller.PBX.originationChan]) by the origination request.
   * This is picked up by this function which then filters the channels from the
   * call list.
   * Upon call transfer, we also create a channel, but cannot (easily) tag the
   * channels, so we merely filter based upon whether or not they have a
   * [Other-Leg-Username] key in the map. This is probably over-simplifying things
   * and may be troublesome when throwing around local calls. This has yet to be
   * tested, however.
   */
  void _createCall(ESL.Packet packet) {
    const String context = '${className}._createCall';


    ESL.Channel channel = ChannelList.instance.get(packet.uniqueID);

    /// Skip local channels
    if (packet.contentAsMap.containsKey ('variable_${Controller.PBX.originationChan}')) {
      logger.debugContext('Skipping origination channel ${packet.uniqueID}', context);
      return;
    }

    if (packet.contentAsMap.containsKey ('Other-Leg-Username')) {
      logger.debugContext('Skipping transfer channel ${packet.uniqueID}', context);
      return;
    }



    logger.debugContext('Creating new call ${packet.uniqueID}', context);


    int contactID = packet.contentAsMap.containsKey('variable_contact_id')
                     ? int.parse(packet.field('variable_contact_id'))
                     : ORModel.Contact.noID;

    int receptionID = packet.contentAsMap.containsKey('variable_reception_id')
                       ? int.parse(packet.field('variable_reception_id'))
                       : ORModel.Reception.noID;

    int userID  = packet.contentAsMap.containsKey('variable_owner')
                   ? int.parse(packet.field('variable_owner'))
                   : ORModel.User.nullID;

    Call createdCall = new Call()
        ..ID = packet.uniqueID
        ..inbound = (packet.field('Call-Direction') == 'inbound' ? true : false)
        ..callerID = packet.field('Caller-Caller-ID-Number')
        ..destination = packet.field('Caller-Destination-Number')
        ..receptionID = receptionID
        ..contactID   = contactID
        ..assignedTo  = userID;


      this._map[packet.uniqueID] = createdCall;
    }

  }

