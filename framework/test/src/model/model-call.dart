part of openreception.test;

void testModelCall() {
  group('Model.Call', () {
    test('serialization', ModelCall.serialization);
    test('deserialization', ModelCall.serialization);
    test('buildObject', ModelCall.buildObject);
    test('callStateStream', ModelCall.callStateStream);
    test('callStateUnknownToCreated', ModelCall.callStateUnknownToCreated);
    test('callStateCreatedToRinging', ModelCall.callStateCreatedToRinging);
    test('callStateParkToHangup', ModelCall.callStateParkToHangup);
    test('callEventStream', ModelCall.callEventStream);

  });
}

abstract class ModelCall {

  /**
   * Merely asserts that no exceptions arise.
   */
  static void serialization() {
    Model.Call builtObject = buildObject();

    expect(() => JSON.encode(builtObject), returnsNormally);
  }
  /**
   * Asserts that the event stream spawns events.
   */
  static Future callEventStream() {
    List<Event.Event> stateChanges = [];

    Model.Call builtObject = buildObject()
      ..event.listen(stateChanges.add);

    int initialStateChangeCount = stateChanges.length;

    builtObject.changeState(Model.CallState.Created);

    return new Future.delayed(new Duration(milliseconds : 20), () {
      expect (stateChanges.length, equals (initialStateChangeCount+1));
      expect (stateChanges.last, new isInstanceOf<Event.Event>());
    });
  }


  /**
   * Asserts that the stream spawns events.
   */
  static Future callStateStream() {
    List<String> stateChanges = [];

    Model.Call builtObject = buildObject()
        ..callState.listen(stateChanges.add);

    int initialStateChangeCount = stateChanges.length;

    builtObject.state = Model.CallState.Transferring;

    return new Future.delayed(new Duration(milliseconds : 20), () {
      expect (stateChanges.length, equals (initialStateChangeCount+1));
    });
  }

  /**
   * Asserts that the stream spawns the correct event.
   */
  static Future callStateUnknownToCreated() {
    List<String> stateChanges = [];

    Model.Call builtObject = buildObject()
        ..callState.listen(stateChanges.add);

    int initialStateChangeCount = stateChanges.length;

    builtObject.state = Model.CallState.Unknown;
    builtObject.state = Model.CallState.Created;

    return new Future.delayed(new Duration(milliseconds : 20), () {
      expect (stateChanges.length, equals (initialStateChangeCount+2));
      expect (stateChanges.last, equals(Model.CallState.Created));
    });
  }

  /**
   * Asserts that the stream spawns events in the correct order.
   */
  static Future callStateParkToHangup() {
    List<String> stateChanges = [];

    Model.Call builtObject = buildObject()
        ..callState.listen(stateChanges.add);

    int initialStateChangeCount = stateChanges.length;

    builtObject.state = Model.CallState.Parked;
    builtObject.state = Model.CallState.Hungup;

    return new Future.delayed(new Duration(milliseconds : 20), () {
      expect (stateChanges.length, equals (initialStateChangeCount+2));
      expect (stateChanges[stateChanges.length-2], equals(Model.CallState.Parked));
      expect (stateChanges.last, equals(Model.CallState.Hungup));
    });
  }

  /**
   * Asserts that the stream spawns the correct event.
   */
  static Future callStateCreatedToRinging() {
    List<String> stateChanges = [];

    Model.Call builtObject = buildObject()
        ..callState.listen(stateChanges.add);

    int initialStateChangeCount = stateChanges.length;

    builtObject.state = Model.CallState.Created;
    builtObject.state = Model.CallState.Ringing;

    return new Future.delayed(new Duration(milliseconds : 20), () {
      expect (stateChanges.length, equals (initialStateChangeCount+2));
      expect (stateChanges.last, equals(Model.CallState.Ringing));
    });
  }

  /**
   * Merely asserts that no exceptions arise.
   */
  static void deserialization() {
    Model.Call builtCall = buildObject();
    String serializedObject = JSON.encode(builtCall);
    Model.Call decodedCall = JSON.decode(serializedObject);

    expect(builtCall.ID, equals(decodedCall.ID));
    expect(builtCall.arrived, equals(decodedCall.arrived));
    expect(builtCall.assignedTo, equals(decodedCall.assignedTo));
    expect(builtCall.b_Leg, equals(decodedCall.b_Leg));
    expect(builtCall.callerID, equals(decodedCall.callerID));
    expect(builtCall.contactID, equals(decodedCall.contactID));
    expect(builtCall.destination, equals(decodedCall.destination));
    expect(builtCall.greetingPlayed, equals(decodedCall.greetingPlayed));
    expect(builtCall.inbound, equals(decodedCall.inbound));
    expect(builtCall.locked, equals(decodedCall.locked));
    expect(builtCall.receptionID, equals(decodedCall.receptionID));
    expect(builtCall.state, equals(decodedCall.state));

    expect(builtCall.toJson(), equals(decodedCall.toJson()));

  }

  static Model.Call buildObject() {
    final String testId = 'test-id';
    final String blegTestId = 'b-leg-test-id';
    final DateTime arrived = new DateTime.now();
    final int assignedTo = 1;
    final String callerId = 'That guy';
    final int contactId = 2;
    final int receptionId = 3;
    final String destination = '12345678';
    final bool greetingPlayed = false;
    final bool inbound = true;
    final bool locked = false;
    final String state = Model.CallState.Created;

    Model.Call builtCall = new Model.Call.empty(testId)
      ..arrived = arrived
      ..assignedTo = assignedTo
      ..b_Leg = blegTestId
      ..callerID = callerId
      ..contactID = contactId
      ..destination = destination
      ..greetingPlayed =greetingPlayed
      ..inbound = inbound
      ..locked = locked
      ..receptionID = receptionId
      ..state = Model.CallState.Created;

    expect(builtCall.ID, equals(testId));
    expect(builtCall.arrived, equals(arrived));
    expect(builtCall.assignedTo, equals(assignedTo));
    expect(builtCall.b_Leg, equals(blegTestId));
    expect(builtCall.callerID, equals(callerId));
    expect(builtCall.contactID, equals(contactId));
    expect(builtCall.destination, equals(destination));
    expect(builtCall.greetingPlayed, equals(greetingPlayed));
    expect(builtCall.inbound, equals(inbound));
    expect(builtCall.locked, equals(locked));
    expect(builtCall.receptionID, equals(receptionId));
    expect(builtCall.state, equals(state));

    return builtCall;
  }
}
