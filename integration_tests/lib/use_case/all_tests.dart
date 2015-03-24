part of or_test_fw;

runUseCaseTests() {

  group ('UseCase.FindContact', () {
    test('1', FindContact.find_contact_1);
    test('2', FindContact.find_contact_2);
  });

  group ('UseCase.ForwardCall', () {
    Transport.Client transport = null;

    setUp (() {
      transport = new Transport.Client();
      ForwardCall.receptionist = ReceptionistPool.instance.aquire();
      ForwardCall.receptionist2 = ReceptionistPool.instance.aquire();
      ForwardCall.caller = CustomerPool.instance.aquire();
      ForwardCall.callee = CustomerPool.instance.aquire();
      ForwardCall.receptionStore = new Service.RESTReceptionStore
          (Config.receptionStoreUri, Config.serverToken, transport);

      return Future.wait([ForwardCall.receptionist.initialize(),
                          ForwardCall.receptionist2.initialize(),
                          ForwardCall.caller.initialize(),
                          ForwardCall.callee.initialize()]);
    });

    tearDown (() {
      ForwardCall.receptionStore = null;

      transport.client.close(force : false);

      return Future.wait([ForwardCall.receptionist.teardown(),
                          ForwardCall.receptionist2.teardown(),
                          ForwardCall.caller.teardown(),
                          ForwardCall.callee.teardown()]);
    });



    test('1 a I', ForwardCall.forward_call_1_a_I);
    test('2', FindContact.find_contact_2);
  });

  group ('UseCase.IncomingCall', () {
    Transport.Client transport = null;

    setUp (() {
      transport = new Transport.Client();
      IncomingCall.receptionist = ReceptionistPool.instance.aquire();
      IncomingCall.receptionist2 = ReceptionistPool.instance.aquire();
      IncomingCall.caller = CustomerPool.instance.aquire();
      IncomingCall.callee = CustomerPool.instance.aquire();
      IncomingCall.receptionStore = new Service.RESTReceptionStore
          (Config.receptionStoreUri, Config.serverToken, transport);

      return Future.wait([IncomingCall.receptionist.initialize(),
                          IncomingCall.receptionist2.initialize(),
                          IncomingCall.caller.initialize(),
                          IncomingCall.callee.initialize()]);
    });

    tearDown (() {
      IncomingCall.receptionStore = null;

      transport.client.close(force : false);

      return Future.wait([IncomingCall.receptionist.teardown(),
                          IncomingCall.receptionist2.teardown(),
                          IncomingCall.caller.teardown(),
                          IncomingCall.callee.teardown()]);
    });


    test('I 1 a i', IncomingCall.incomingCall_I_1_a_i);
    test('I 1 a ii', IncomingCall.incomingCall_I_1_a_ii);
    test('I 1 b i', IncomingCall.incomingCall_I_1_b_i);
    test('I 1 b ii', IncomingCall.incomingCall_I_1_b_ii);
    //test('2', FindContact.find_contact_2);
  });

}