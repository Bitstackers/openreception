import 'dart:async' as async;

import 'package:phonio/phonio.dart';
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/service-io.dart' as Transport;
import '../lib/or_test_fw.dart';

import '../lib/managementserver.dart' as mgt;

import 'package:logging/logging.dart';

const String pbxHost = '192.168.1.136';

abstract class Config {

  static const String ServerToken = 'feedabbadeadbeef0';
}


final SIPAccount account1107 =
  new SIPAccount(new SNOMPhone(Uri.parse('http://${SNOMphonesHostnames['1107']}')))
    ..username = '1107'
    ..password = '1234'
    ..server = pbxHost
    ..SIPPort = 5767;

final SIPAccount account1108 =
  new SIPAccount(new SNOMPhone(Uri.parse('http://${SNOMphonesHostnames['1108']}')))
    ..username = '1108'
    ..password = '1234'
    ..server = pbxHost
    ..SIPPort = 5768;

final SIPAccount account1109 =
  new SIPAccount(new SNOMPhone(Uri.parse('http://${SNOMphonesHostnames['1109']}')))
    ..username = '1109'
    ..password = '1234'
    ..server = pbxHost
    ..SIPPort = 5769;
/*
final Map<String, String> SNOMphonesHostnames =
{'1109' : '192.168.2.198',
 '1108' : '192.168.2.197',
 '1107' : '192.168.2.192'};
*/

final Map<String, String> SNOMphonesHostnames =
{'1107' : 'snom360-295AD1.home.gir.dk',
 '1108' : 'snom320-383ad8.home.gir.dk',
 '1109' : 'snom720-771C98.home.gir.dk'};

Map<String, SNOMPhone> SNOMphonesResolutionMap = {};

async.Future initSNOMPhones() {

  [account1107, account1108, account1109].forEach((SIPAccount account)
      => SNOMphonesResolutionMap.addAll({account.username : account.phone}));

  SNOMphonesResolutionMap.forEach((id, phone) =>
      phone.eventStream.listen((event) => print ('EVENT: $id $event')));

  SNOMActionGateway snomgw = new SNOMActionGateway(SNOMphonesResolutionMap);
    return snomgw.start(hostname: pbxHost)
      .then((_) => snomgw.phones.values.forEach((SNOMPhone p) {
      p.setActionURL(snomgw.actionUrls);
    }));


//  SNOMActionGateway snomgw = new SNOMActionGateway(SNOMphonesResolutionMap);
//  snomgw.start(hostname: pbxHost)
//    .then((_) => snomgw.phones.values.forEach((SNOMPhone p) => p.setActionURL(snomgw.actionUrls)));
//  SNOMPhone phone = snomgw.phones['1107'];
//
//
//  snomgw.phones.values.forEach((SNOMPhone p) => p.autoAnswer(true));
}

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  //testPJSUA();
  //testSNOM();
  //testServerStack();


  initSNOMPhones();

  List customers = [new Customer(SNOMphonesResolutionMap['1107'])];
  List receptionists = [new Receptionist(SNOMphonesResolutionMap['1108'], 'feedabbadeadbeef8', 18),
                        new Receptionist(SNOMphonesResolutionMap['1109'], 'feedabbadeadbeef9', 19)];

  CustomerPool.instance = new CustomerPool(customers)
    ..onRelease = (Customer customer) => customer.hangupAll();
  ReceptionistPool.instance = new ReceptionistPool(receptionists)
     ..onRelease = (Receptionist receptionist) => receptionist.hangupAll();;

  //Message.send_message_1_a();
  IncomingCall.incomingCall_1_a_II();

  //FindContact.findContact_1();

  //testPJSUA();
  //testSNOM();

//  Receptionist r1 = new Receptionist(null);
//
//  r1.callFlowControl = new Service.CallFlowControl
//      (Uri.parse('http://localhost:4242'), 'feedabbadeadbeef9', new Transport.Client());
//
//  Service.Notification.socket(Uri.parse("ws://localhost:4200"), "feedabbadeadbeef0")
//    .then((ws) {
//      r1.notificationSocket = ws;
//      //r1.notificationSocket.eventStream.listen((e) => print(e.asMap));
//
//
//      r1.originate('12340001', 1, 1).then(print);
//    });
//
}

void testSNOM (){
  Map<String, SNOMPhone> SNOMphonesResolutionMap = {};

  [account1107, account1108, account1109].forEach((SIPAccount account)
      => SNOMphonesResolutionMap.addAll({account.username : account.phone}));

  SNOMphonesResolutionMap.forEach((id, phone) =>
      phone.eventStream.listen((event) => print ('EVENT: $id $event')));

  SNOMActionGateway snomgw = new SNOMActionGateway(SNOMphonesResolutionMap);
  snomgw.start(hostname: pbxHost)
    .then((_) => snomgw.phones.values.forEach((SNOMPhone p) => p.setActionURL(snomgw.actionUrls)));
  SNOMPhone phone = snomgw.phones['1107'];


  snomgw.phones.values.forEach((SNOMPhone p) => p.autoAnswer(true));


  ReceptionistPool receptionistPool =
      new ReceptionistPool(snomgw.phones.values.map((SNOMPhone phone)
                              => new Receptionist(phone)));

  Receptionist receptionist = receptionistPool.aquire();

  phone.originate ('1108').then((Call call) {
    print (call);
    phone.hangupCurrentCall();
  });

  phone.originate ('1109').then((_) =>
    phone.hangupCurrentCall());

  phone.originate ('1109')
  .then((_) => new async.Future.delayed(new Duration(seconds : 1), () => phone.hangupCurrentCall() )
  .then((_) => new async.Future.delayed(new Duration(seconds : 1), () => phone.originate ('1109')) )
  .then((_) => new async.Future.delayed(new Duration(seconds : 1), () => phone.hangupCurrentCall() )
  ));

}



abstract class Hangup {

  static Logger log = new Logger('Test.Hangup');

  /**
   * Test for the presence of hangup events and call interface.
   */
  static void eventPresence() {
    Receptionist receptionist = receptionistPool.aquire();
    Customer     customer     = customerPool.aquire();

    String       reception = "12340001";

    log.finest ("Customer " + customer.name + " dials " + reception);

    customer.dial (reception)
      .then((Call customerCall) {
        receptionist.waitForCall()
          .then((_) => customer.hangup (customerCall))
          .then((_) => receptionist.waitFor(eventType:"call_hangup"));

    }).whenComplete(() {
      receptionistPool.release(receptionist);
      customerPool.release(customer);
    });

  }
}

void testHangup() {
/*

  def test_interface_call_found(self):
      test_receptionist = Receptionists.request()
      test_customer = Customers.request()

      try:
          reception = "12340001"

          self.log.info ("Customer " + test_customer.username + " dials " + reception)
          test_customer.sip_phone.Dial(reception)
          test_receptionist.event_stack.WaitFor(event_type="call_offer")

          test_customer.sip_phone.HangupAllCalls()
          test_receptionist.event_stack.WaitFor(event_type="call_hangup")
          test_receptionist.event_stack.flush()

          test_customer.sip_phone.Dial(reception)
          test_receptionist.event_stack.WaitFor(event_type="call_offer")
          self.log.info ("Extracting latest event.")
          offered_call = test_receptionist.event_stack.Get_Latest_Event (Event_Type ="call_offer",
                                                                         Destination=reception)['call']
          self.log.info  ("Got offered call " + str(offered_call['id']) + " - picking it up.")
          test_receptionist.pickup_call_wait_for_lock(call_id=offered_call['id'])

          test_receptionist.event_stack.WaitFor(event_type="call_pickup")
          test_receptionist.hang_up(call_id=offered_call['id'])
          test_receptionist.event_stack.WaitFor(event_type="call_hangup")

          test_receptionist.release()
          test_customer.release()
      except:
          self.log.debug(test_receptionist.event_stack.dump_stack())
          test_receptionist.release()
          test_customer.release()
          raise
*/
}

void testPJSUA() {
  String binaryPath = '/home/krc/Projects/Coverage_Tests/bin/basic_agent';

  PJSUAProcess sip = new PJSUAProcess(account1109, binaryPath)
                     ..eventStream.listen((event) => print ('1109:$event'));
  PJSUAProcess sip2 = new PJSUAProcess(account1108, binaryPath)
                     ..eventStream.listen((event) => print ('1108:$event'));
  sip.connect().catchError(print);
  sip2.connect().catchError(print);

  sip.whenReady().then((_) {
    print("Process1 is ready.");
    sip2.whenReady().then((_) {
      print("Process1 is ready.");
      sip2.registerAccount()
      .then((response) => print ('1108 Register returned: $response'));
    });


    sip.registerAccount()
      .then((response) => print ('1109 Register returned: $response'))
      .then((_) => sip.originate('12340001')).then((_) {
      sip.originate('1108');
    });
  });

}

/*
class Phone {
  List<Call> activeCalls;

  void originate (String extension) {
    this._process.send("+D)
  }

}

abstract class CallState {
  static const String UNKNOWN  = 'UNKNOWN';
  static const String HELD     = 'HELD';
  static const String SPEAKING = 'SPEAKING';
  static const String RINGING  = 'HELD';
}

class Call {
  String state = CallState.UNKNOWN;


}


class Receptionist extends Phone {

}*/

void testServerStack() {
  mgt.runAllTests();
}
