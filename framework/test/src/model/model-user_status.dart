part of openreception.test;

testModelUserStatus() {
  group('Model.Status', () {

    test('buildObject', ModelUserStatus.buildObject);
  });
}

abstract class ModelUserStatus {

  static Model.UserStatus buildObject () {
    final int callsHandled = 1;
    final DateTime lastActivity = new DateTime.now();
    final String state = Model.UserState.Parking;
    final int userID = 2;

    Model.UserStatus builtObject = new Model.UserStatus()
      ..callsHandled = callsHandled
      ..lastActivity = lastActivity
      ..state = state
      ..userID = userID;

    expect(builtObject.callsHandled, equals(callsHandled));
    expect(builtObject.lastActivity, equals(lastActivity));
    expect(builtObject.lastState, equals(Model.UserState.Unknown));
    expect(builtObject.state, equals(state));
    expect(builtObject.userID, equals(userID));

    return builtObject;
  }

}