part of or_test_fw;

class Customer {

  Phonio.Call currentCall = null;

  Phonio.SIPPhone _phone = null;
  String get name => this._phone.defaultAccount.username;

  Customer (this._phone);

  /**
   * Dials an extension and returns a future with a call object.
   */
  Future<Phonio.Call> dial(String extension) => this._phone.originate(extension);


  Future hangup(Phonio.Call call) =>
    new Future (() => throw new StateError('Not implemented'));

  Future waitForIncomingCall () => new
      Future (() => throw new StateError('Not implemented'));

}

