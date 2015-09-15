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

class Busy implements Exception {

  final String message;
  const Busy([this.message = ""]);

  String toString() => "Forbidden: $message";
}

class CallList extends IterableBase<ORModel.Call> {

  static final Logger log = new Logger('${libraryName}.CallList');

  Map<String, ORModel.Call> _map = new Map<String, ORModel.Call>();

  Iterator get iterator => this._map.values.iterator;

  Bus<OREvent.CallEvent> _callEvent = new Bus<OREvent.CallEvent>();
  Stream<OREvent.CallEvent> get onEvent => this._callEvent.stream;

  static CallList instance = new CallList();

  List toJson() => this.toList(growable: false);

  bool containsID (String callID) => this._map.containsKey(callID);

  void subscribe(Stream<ESL.Event> eventStream) {
    eventStream.listen(_handleEvent);
  }

  /**
   * WIP. The main idea of this was that call list was merely a reflection of
   * the current channel list (which could be reloaded at arbitrary times).
   * The gain of this would be that no pseudo-state would be present in the
   * call-flow-control service.
   */
  void subscribeChannelEvents(Stream<ChannelEvent> eventStream) {
    //eventStream.listen(_handleChannelsEvent);
  }

  /**
   * Reload the call list from an Iterable of channels.
   */
  void reloadFromChannels (Iterable<ESL.Channel> channels) {
    Map<String, ORModel.Call> calls = {};

    channels.forEach((ESL.Channel channel) {
      if (!channel.variables.containsKey(Controller.PBX.agentChan)) {
        calls[channel.UUID] = new ORModel.Call.empty(channel.UUID)
        ..arrived = new DateTime.fromMillisecondsSinceEpoch(int.parse(channel.fields['Caller-Channel-Created-Time'])~/1000)
        ..assignedTo = channel.variables.containsKey(Controller.PBX.ownerUid)
          ? int.parse(channel.variables[Controller.PBX.ownerUid])
          : ORModel.User.noID
        ..b_Leg = channel.fields['Other-Leg-Unique-ID']
        ..greetingPlayed = channel.variables.containsKey(Controller.PBX.greetingPlayed)
            ? channel.variables[Controller.PBX.greetingPlayed] == 'true'
            : false
        ..locked = channel.variables.containsKey(Controller.PBX.locked)
            ? channel.variables[Controller.PBX.locked] == 'true'
            : false
        ..inbound = (channel.fields['Call-Direction'] == 'inbound' ? true : false)
        ..callerID = channel.fields['Caller-Caller-ID-Number']
        ..destination = channel.fields['Caller-Destination-Number']
        ..receptionID = channel.variables.containsKey('reception_id')
            ? int.parse(channel.variables['reception_id'])
            : ORModel.Reception.noID
          ;

          log.info(calls[channel.UUID].arrived);
      }
      else {
        log.info('Ignoring local channel ${channel.UUID}');
      }

    });

    ///Extract the call state.
    calls.values.forEach((ORModel.Call call) {
      if(call.b_Leg != null) {
        log.info('$call is bridged.');
        final ESL.Channel aLeg = ChannelList.instance.get(call.channel);
        final ESL.Channel bLeg = ChannelList.instance.get(call.b_Leg);

        if (isCall(aLeg) && isCall(bLeg)) {
          call.state = ORModel.CallState.Transferred;
        }
        else {
          call.state = ORModel.CallState.Speaking;
        }

      } else {
        log.info('$call is not bridged.');

        if (call.destination == 'waitqueue') {
          call.state = ORModel.CallState.Queued;
        }
        else if (call.destination == 'park') {
          call.state = ORModel.CallState.Parked;
        }

        else {
          log.severe('state of $call not updated!');
        }
      }
    });

    this._map = calls;
  }

  List<ORModel.Call> callsOf(int userID) =>
      this.where((ORModel.Call call) => call.assignedTo == userID).toList();


  ORModel.Call get(String callID) {
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

  ORModel.Call requestCall(user) =>
    //TODO: Implement a real algorithm for selecting calls.
    this.firstWhere((ORModel.Call call) => call.assignedTo == ORModel.User.noID &&
      !call.locked, orElse: () => throw new NotFound ("No calls available"));

  ORModel.Call requestSpecificCall(String callID, ORModel.User user )  {

    ORModel.Call call = this.get(callID);

    if (![user.ID, ORModel.User.noID].contains(call.assignedTo)) {
      log.warning('Call ${callID} already assigned to uid: ${call.assignedTo}');
      throw new Forbidden(callID);
    } else if (call.locked) {
      log.fine('Uid ${user.ID} requested locked call $callID');
      throw new Busy(callID);
    }

    return call;
  }

  bool isCall (ESL.Channel channel) =>
      this.containsID (channel.UUID);


  void _handleBridge(ESL.Packet packet) {

    final ESL.Channel aLeg = ChannelList.instance.get(packet.field('Bridge-A-Unique-ID'));
    final ESL.Channel bLeg = ChannelList.instance.get(packet.field('Bridge-B-Unique-ID'));

    log.finest('Bridging channel ${aLeg} and channel ${bLeg}');

    if (isCall(aLeg) && isCall(bLeg)) {
      CallList.instance.get(aLeg.UUID).b_Leg = bLeg.UUID;
      CallList.instance.get(bLeg.UUID).b_Leg = aLeg.UUID;

      CallList.instance.get(aLeg.UUID).changeState (ORModel.CallState.Transferred);
      CallList.instance.get(bLeg.UUID).changeState (ORModel.CallState.Transferred);
    }

    else if (isCall(aLeg)) {
      CallList.instance.get(aLeg.UUID).b_Leg = bLeg.UUID;
      CallList.instance.get(aLeg.UUID).changeState (ORModel.CallState.Speaking);
    }

    else if (isCall(bLeg)) {
      CallList.instance.get(bLeg.UUID).b_Leg = aLeg.UUID;
      CallList.instance.get(bLeg.UUID).changeState (ORModel.CallState.Speaking);
    }

    // Local calls??
    else {
      log.severe('Local calls are not supported!');
    }
  }

  void _handleChannelDestroy (ESL.Event event) {
    if (this.containsID(event.uniqueID)) {
      this.get(event.uniqueID).changeState(ORModel.CallState.Hungup);
      log.finest('Hanging up ${event.uniqueID}');
      this.remove(event.uniqueID);
    }
  }


  void _handleCustom (ESL.Event event) {
    switch (event.eventSubclass) {

      /// Entering the prequeue (not yet answered).
      case (PBXEvent._OR_PRE_QUEUE_ENTER):
        this._createCall(event);

        this.get(event.uniqueID)
            ..destination = event.field('Caller-Destination-Number')
            ..receptionID =
              event.contentAsMap.containsKey('variable_reception_id')
                        ? int.parse(event.field('variable_reception_id'))
                        : 0
            ..changeState(ORModel.CallState.Created);

        break;

      /// Leaving the prequeue (Playing greeting and locking the call)
      case (PBXEvent._OR_PRE_QUEUE_LEAVE):
        ESL.Channel channel = new ESL.Channel.fromPacket(event);

        log.finest('Locking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..changeState (ORModel.CallState.Transferring)
          ..locked = channel.variables.containsKey(Controller.PBX.locked)
              ? channel.variables[Controller.PBX.locked] == 'true'
              : false;
        break;

      /// Entering the wait queue (Playing queue music)
      case (PBXEvent._OR_WAIT_QUEUE_ENTER):
        ESL.Channel channel = new ESL.Channel.fromPacket(event);

        log.finest('Unlocking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..destination = event.field('Caller-Destination-Number')
          ..locked = channel.variables.containsKey(Controller.PBX.locked)
              ? channel.variables[Controller.PBX.locked] == 'true'
              : false

        ..greetingPlayed = true //TODO: Change this into a packet.variable.get ('greetingPlayed')
          ..changeState (ORModel.CallState.Queued);
        break;

      /// Call is parked
      case (PBXEvent._OR_PARKING_LOT_ENTER):
        CallList.instance.get (event.uniqueID)
          ..destination = event.field('Caller-Destination-Number')
          ..b_Leg = null
          ..changeState (ORModel.CallState.Parked);
        break;

      /// Call is unparked
      case (PBXEvent._OR_PARKING_LOT_LEAVE):
        CallList.instance.get (event.uniqueID)
          ..changeState (ORModel.CallState.Transferring);
        break;


      //FIXME: Remove this duplicate block when all dialplans have been updated
      case (PBXEvent._AH_PRE_QUEUE_ENTER):
        this._createCall(event);

        this.get(event.uniqueID)
            ..destination = event.field('Caller-Destination-Number')
            ..receptionID =
              event.contentAsMap.containsKey('variable_reception_id')
                        ? int.parse(event.field('variable_reception_id'))
                        : 0
            ..changeState(ORModel.CallState.Created);

        break;

//      case ("AdaHeads::outbound-call"):
//         log.finest('Outbound call: ${event.uniqueID}');
//         this._createCall(event);
//
//         break;
      //FIXME: Remove this duplicate block when all dialplans have been updated
      case (PBXEvent._AH_PRE_QUEUE_LEAVE):
        log.finest('Locking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..changeState (ORModel.CallState.Transferring)
          ..locked = true;
        break;

      //FIXME: Remove this duplicate block when all dialplans have been updated
      case (PBXEvent._AH_WAIT_QUEUE_ENTER):
        log.finest('Unlocking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..destination = event.field('Caller-Destination-Number')
          ..locked = false
          ..greetingPlayed = true //TODO: Change this into a packet.variable.get ('greetingPlayed')
          ..changeState (ORModel.CallState.Queued);
        break;

      //FIXME: Remove this duplicate block when all dialplans have been updated
      case (PBXEvent._AH_PARKING_LOT_ENTER):
        CallList.instance.get (event.uniqueID)
          ..changeState (ORModel.CallState.Parked);
        break;

      //FIXME: Remove this duplicate block when all dialplans have been updated
      case (PBXEvent._AH_PARKING_LOT_LEAVE):
        CallList.instance.get (event.uniqueID)
          ..changeState (ORModel.CallState.Transferring);
        break;
    }
  }


  void _handleEvent(ESL.Event event) {

    void dispatch () {
      switch (event.eventName) {

        case (PBXEvent.CHANNEL_BRIDGE):
          this._handleBridge(event);
          break;

//        case ('CHANNEL_STATE'):
//          this._handleChannelState(event);
//          break;

        /// OUtbound calls
        case (PBXEvent.CHANNEL_ORIGINATE):
          this._createCall(event);
          break;

        case (PBXEvent.CHANNEL_DESTROY):
          this._handleChannelDestroy(event);
          break;

        case (PBXEvent.CUSTOM):
          this._handleCustom(event);
          break;
      }
    }


    try {
      dispatch();
    }
    catch (error, stackTrace) {
      log.severe('Failed to dispatch event ${event.eventName}');
      log.severe(error, stackTrace);
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
   * variable ([agentChan]) by the origination request.
   * This is picked up by this function which then filters the channels from the
   * call list.
   * Upon call transfer, we also create a channel, but cannot (easily) tag the
   * channels, so we merely filter based upon whether or not they have a
   * [Other-Leg-Username] key in the map. This is probably over-simplifying things
   * and may be troublesome when throwing around local calls. This has yet to be
   * tested, however.
   */
  void _createCall(ESL.Event event) {
    /// Skip local channels
    if (event.contentAsMap.containsKey ('variable_${Controller.PBX.agentChan}')) {
      log.finest('Skipping origination channel ${event.uniqueID}');
      return;
    }

    if (event.contentAsMap.containsKey ('Other-Leg-Username')) {
      log.finest('Skipping transfer channel ${event.uniqueID}');
      return;
    }



    log.finest('Creating new call ${event.uniqueID}');

    int contactID = event.contentAsMap.containsKey('variable_contact_id')
                     ? int.parse(event.field('variable_contact_id'))
                     : ORModel.Contact.noID;

    int receptionID = event.contentAsMap.containsKey('variable_reception_id')
                       ? int.parse(event.field('variable_reception_id'))
                       : ORModel.Reception.noID;

    int userID  = event.contentAsMap.containsKey('variable_owner')
                   ? int.parse(event.field('variable_owner'))
                   : ORModel.User.noID;

    ORModel.Call createdCall = new ORModel.Call.empty(event.uniqueID)
        ..arrived = new DateTime.fromMillisecondsSinceEpoch(int.parse(event.field('Caller-Channel-Created-Time'))~/1000)
        ..inbound = (event.field('Call-Direction') == 'inbound' ? true : false)
        ..callerID = event.field('Caller-Caller-ID-Number')
        ..destination = event.field('Caller-Destination-Number')
        ..receptionID = receptionID
        ..contactID   = contactID
        ..assignedTo  = userID
        ..event.listen(this._callEvent.fire);

      this._map[event.uniqueID] = createdCall;
    }
}