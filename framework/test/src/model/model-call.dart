part of openreception.test;

void testModelCall() {
  group('Model.Call', () {
    test('serialization', ModelCall.serialization);
    test('deserialization', ModelCall.serialization);
    test('buildObject', ModelCall.buildObject);
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
      ..state = state;

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
