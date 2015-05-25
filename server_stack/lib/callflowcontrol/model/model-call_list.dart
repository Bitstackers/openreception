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

class CallList extends IterableBase<Call> {

  static final Logger log = new Logger('${libraryName}.CallList');

  Map<String, Call> _map = new Map<String, Call>();

  Iterator get iterator => this._map.values.iterator;

  Bus<Call> _callStateChange = new Bus<Call>();
  Stream<Call> get onCallStateChange => this._callStateChange.stream;

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
          throw new ArgumentError('Bad channel event name: '
                                  ' ${channelEvent.eventName}');
      }
    }


  try {
    dispatch();
  } catch (error, stackTrace) {
    log.severe('Failed to dispatch channelEvent $channelEvent');
    log.severe(error, stackTrace);
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
    this.firstWhere((Call call) => call.assignedTo == ORModel.User.nullID &&
      !call.locked, orElse: () => throw new NotFound ("No calls available"));

  Call requestSpecificCall(String callID, ORModel.User user )  {

    Call call = this.get(callID);

    if (![user.ID, ORModel.User.nullID].contains(call.assignedTo)) {
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
      log.severe('Local calls are not supported!');
    }
  }

  void _handleChannelDestroy (ESL.Event event) {
    if (this.containsID(event.uniqueID)) {
      this.get(event.uniqueID).changeState(CallState.Hungup);
      log.finest('Hanging up ${event.uniqueID}');
      this._callStateChange.fire(this.get(event.uniqueID));
      this.remove(event.uniqueID);
    }
  }


  void _handleCustom (ESL.Event event) {
    switch (event.eventSubclass) {
      case ("AdaHeads::pre-queue-enter"):
        this._createCall(event);

        this.get(event.uniqueID)
            ..receptionID =
              event.contentAsMap.containsKey('variable_reception_id')
                        ? int.parse(event.field('variable_reception_id'))
                        : 0
            ..changeState(CallState.Created);

        break;

//      case ("AdaHeads::outbound-call"):
//         log.finest('Outbound call: ${event.uniqueID}');
//         this._createCall(event);
//
//         break;

      case ('AdaHeads::pre-queue-leave'):
        log.finest('Locking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..changeState (CallState.Transferring)
          ..locked = true;
        break;

      case ('AdaHeads::wait-queue-enter'):
        log.finest('Unlocking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..locked = false
          ..greetingPlayed = true //TODO: Change this into a packet.variable.get ('greetingPlayed')
          ..changeState (CallState.Queued);
        break;

      case ('AdaHeads::parking-lot-enter'):
        CallList.instance.get (event.uniqueID)
          ..changeState (CallState.Parked);
        break;

      case ('AdaHeads::parking-lot-leave'):
        CallList.instance.get (event.uniqueID)
          ..changeState (CallState.Transferring);
        break;
    }
  }


  void _handleEvent(ESL.Event event) {

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
   * variable ([Controller.PBX.originationChan]) by the origination request.
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
    if (event.contentAsMap.containsKey ('variable_${Controller.PBX.originationChan}')) {
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
                   : ORModel.User.nullID;

    Call createdCall = new Call()
        ..ID = event.uniqueID
        ..inbound = (event.field('Call-Direction') == 'inbound' ? true : false)
        ..callerID = event.field('Caller-Caller-ID-Number')
        ..destination = event.field('Caller-Destination-Number')
        ..receptionID = receptionID
        ..contactID   = contactID
        ..assignedTo  = userID;

      this._map[event.uniqueID] = createdCall;
    }

  }

