/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.call_flow_control_server.model;

class CallList extends IterableBase<ORModel.Call> {

  static final Logger log = new Logger('${libraryName}.CallList');

  Map<String, ORModel.Call> _map = new Map<String, ORModel.Call>();

  Iterator get iterator => this._map.values.iterator;

  Bus<OREvent.Event> _callEvent = new Bus<OREvent.Event>();
  Stream<OREvent.Event> get onEvent => this._callEvent.stream;

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
        ..callerID =
          channel.fields.containsKey('Caller-Orig-Caller-ID-Number')
          ? channel.fields['Caller-Orig-Caller-ID-Number']
          : channel.fields['Caller-Caller-ID-Number']
        ..destination = channel.variables['openreception::destination']
        ..receptionID = channel.variables.containsKey('reception_id')
            ? int.parse(channel.variables['reception_id'])
            : ORModel.Reception.noID
        ..contactID = channel.variables.containsKey('contact_id')
            ? int.parse(channel.variables['contact_id'])
            : ORModel.Contact.noID
        ..event.listen(this._callEvent.fire);

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
          call.state = aLeg.fields['Answer-State'] == 'ringing'
              ? ORModel.CallState.Ringing
              : ORModel.CallState.Speaking;
        }

      } else {
        log.info('$call is not bridged.');
        final String orState = ChannelList.instance.get(call.channel)
            .variables['openreception::state'];

        if (orState == 'queued') {
          call.state = ORModel.CallState.Queued;
        }
        else if (orState == 'parked') {
          call.state = ORModel.CallState.Parked;
        }
        else if (orState == 'ringing') {
          call.state = ORModel.CallState.Ringing;
        }

        else {
          log.severe('state of $call not updated!');
        }
      }
    });

    this._map = calls;

    this._callEvent.fire(new OREvent.CallStateReload());
  }

  List<ORModel.Call> callsOf(int userID) =>
      this.where((ORModel.Call call) => call.assignedTo == userID).toList();

  ORModel.Call get(String callID) {
    if (this._map.containsKey(callID)) {
      return this._map[callID];
    } else {
      throw new ORStorage.NotFound(callID);
    }
  }

  void remove (String callID) {
    if (this._map.containsKey(callID)) {
      this._map.remove(callID);
    } else {
      throw new ORStorage.NotFound(callID);
    }
  }

  ORModel.Call requestCall(user) =>
    //TODO: Implement a real algorithm for selecting calls.
    this.firstWhere((ORModel.Call call) => call.assignedTo == ORModel.User.noID &&
      !call.locked, orElse: () => throw new ORStorage.NotFound ("No calls available"));

  ORModel.Call requestSpecificCall(String callID, ORModel.User user )  {

    ORModel.Call call = this.get(callID);

    if (![user.ID, ORModel.User.noID].contains(call.assignedTo)) {
      log.fine('Call ${callID} already assigned to uid: ${call.assignedTo}');
      throw new ORStorage.Forbidden(callID);
    } else if (call.locked) {
      log.fine('Uid ${user.ID} requested locked call $callID');
      throw new ORStorage.Conflict(callID);
    }

    return call;
  }

  bool isCall (ESL.Channel channel) =>
      this.containsID (channel.UUID);

  /**
   * Handle CHANNEL_BRIDGE event packets.
   */
  void _handleBridge(ESL.Packet packet) {

    final ESL.Channel uuid = ChannelList.instance.get(packet.field('Unique-ID'));
    final ESL.Channel otherLeg = ChannelList.instance.get(packet.field('Other-Leg-Unique-ID'));

    log.finest('Bridging channel ${uuid.UUID} and channel ${otherLeg.UUID}');


    if (isCall(uuid) && isCall(otherLeg)) {
      log.finest('Channel ${uuid.UUID} and channel ${otherLeg.UUID} are both calls');
      CallList.instance.get(uuid.UUID)
        ..b_Leg = otherLeg.UUID;
      CallList.instance.get(otherLeg.UUID)
        ..b_Leg = uuid.UUID;

      CallList.instance.get(uuid.UUID).changeState (ORModel.CallState.Transferred);
      CallList.instance.get(otherLeg.UUID).changeState (ORModel.CallState.Transferred);
    }

    else if (isCall(uuid)) {
      ORModel.Call call = CallList.instance.get(uuid.UUID);
      log.finest('Channel ${uuid.UUID} is a call');

      call..b_Leg = otherLeg.UUID
          ..changeState (ORModel.CallState.Speaking);

     _startRecording(call);
    }

    else if (isCall(otherLeg)) {
      ORModel.Call call = CallList.instance.get(otherLeg.UUID);
      log.finest('Channel ${otherLeg.UUID} is a call');
       call..b_Leg = uuid.UUID
           ..changeState (ORModel.CallState.Speaking);

      _startRecording(call);
    }

    // Local calls??
    else {
      log.severe('Local calls are not supported!');
    }
  }

  void _handleChannelDestroy (ESL.Event event) {
    if (this.containsID(event.uniqueID)) {
      final ORModel.Call call = this.get(event.uniqueID);

      if (call.inbound && call.assignedTo != ORModel.User.noID) {
        log.warning('!!!adding a call by agent');
        AgentHistory.instance.callHandledByAgent(call.assignedTo);
      }

      call.changeState(ORModel.CallState.Hungup);
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
            ..receptionID =
              event.contentAsMap.containsKey('variable_reception_id')
                        ? int.parse(event.field('variable_reception_id'))
                        : 0
            ..changeState(ORModel.CallState.Created);

        break;

      /// Leaving the prequeue (Playing greeting and locking the call)
      case (PBXEvent._OR_PRE_QUEUE_LEAVE):
        /// If the call was placed directly into the waitQueue
        if(!this._map.containsKey(event.uniqueID)) {
          this._createCall(event);
        }

        log.finest('Locking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..changeState (ORModel.CallState.Transferring)
          ..locked = event.contentAsMap.containsKey(Controller.PBX.locked)
              ? event.field(Controller.PBX.locked) == 'true'
              : false;
        break;

      /// Entering the wait queue (Playing queue music)
      case (PBXEvent._OR_WAIT_QUEUE_ENTER):
        ESL.Channel channel = new ESL.Channel.fromPacket(event);

        log.finest('Unlocking ${event.uniqueID}');
        CallList.instance.get (event.uniqueID)
          ..locked = channel.variables.containsKey(Controller.PBX.locked)
              ? channel.variables[Controller.PBX.locked] == 'true'
              : false

        ..greetingPlayed = true //TODO: Change this into a packet.variable.get ('greetingPlayed')
          ..changeState (ORModel.CallState.Queued);
        break;

      /// Call is parked
      case (PBXEvent._OR_PARKING_LOT_ENTER):
        CallList.instance.get (event.uniqueID)
          ..b_Leg = null
          ..changeState (ORModel.CallState.Parked);
        break;

      /// Call is unparked
      case (PBXEvent._OR_PARKING_LOT_LEAVE):
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

//        /// OUtbound calls
//        case (PBXEvent.CHANNEL_ORIGINATE):
//          this._createCall(event);
//          break;

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

  ORModel.Call createCall(ESL.Event event) {
    _createCall(event);
    return get(event.uniqueID);
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

    final ESL.Channel channel = new ESL.Channel.fromPacket(event);

    ORModel.Call createdCall = new ORModel.Call.empty(event.uniqueID)
        ..arrived = new DateTime.fromMillisecondsSinceEpoch(int.parse(event.field('Caller-Channel-Created-Time'))~/1000)
        ..inbound = (event.field('Call-Direction') == 'inbound' ? true : false)
        ..callerID = event.field('Caller-Caller-ID-Number')
        ..destination = channel.variables['openreception::destination']
        ..receptionID = receptionID
        ..contactID   = contactID
        ..assignedTo  = userID
        ..event.listen(this._callEvent.fire);

      this._map[event.uniqueID] = createdCall;
    }
}

Future _startRecording(ORModel.Call call) async {
  if(!config.callFlowControl.enableRecordings) {
    return 0;
  }

  final Iterable parts = [
    call.b_Leg,
    call.ID,
    call.receptionID,
    call.inbound
      ? 'in_${call.callerID}'
      : 'out_${call.destination}'];


  final filename = '${parts.join('_')}.wav';

  return Controller.PBX.recordChannel(call.b_Leg, filename)
    .then((_) =>
      log.fine('Started recording call ${call.ID} '
               '(agent channel: ${call.b_Leg})  to file $filename'))
    .catchError((error, stackTrace) =>
      log.severe('Could not start recording of '
                 'call ${call.ID} to file $filename', error, stackTrace));
}