import 'dart:async';

import 'package:logging/logging.dart';
import 'package:phonio/phonio.dart' as Phonio;

import '../lib/or_test_fw.dart' as test_fw;

Logger log = new Logger('Call-Spawner');

void main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  test_fw.SupportTools st;

  test_fw.SupportTools.instance
      .then((test_fw.SupportTools init) => st = init)
      .then((_) => print(st))
      .then((_) => start_spawning());
}

Future start_spawning() async {
  test_fw.CustomerPool.instance.available;

  Set<test_fw.Customer> customers = await getCustomers();

  // Each customer spawns a call
  return Future.forEach(customers, (test_fw.Customer customer) {
    customerAutoDialing(customer);
  });
}

Future customerAutoDialing(test_fw.Customer customer)  {

  customer.phoneEvents.listen((Phonio.Event event)  {

    // Spawn a new call as soon as the old call is disconnected.
    if(event is Phonio.CallDisconnected) {
      customer.dial('12340003');
    }
  });

  int numCalls = 4;
  return Future.doWhile(() {
    numCalls = numCalls - 1;
    return customer.dial('12340003').then((_) {
      return numCalls != 0;
    });
  });


}

Future getCustomers() async {
  Set<test_fw.Customer> customers = new Set();

  while (test_fw.CustomerPool.instance.available.length > 0) {
    customers.add(test_fw.CustomerPool.instance.aquire());
  }

  return Future
      .wait(customers.map((test_fw.Customer customer) => customer.initialize()))
      .then((_) => customers);
}
