import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:phonio/phonio.dart' as Phonio;
import 'dart:math' show Random;

import '../lib/or_test_fw.dart' as test_fw;

Logger log = new Logger('Call-Spawner');

const List<String> _receptionNumbers = const
  ['12340001',
   '12340002',
   '12340003',
   '12340004',
   '12340005',
   '12340006'];
final Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);

dynamic _randomChoice(List pool) {
  if (pool.isEmpty) {
    throw new ArgumentError('Cannot find a random value in an empty list');
  }

  final int index = rand.nextInt(pool.length);

  return pool[index];
}

bool _stopping = false;

void main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  test_fw.SupportTools st;

  ProcessSignal.SIGINT.watch().listen((_) {
    _stopping = true;
    st.tearDown();
    exit(0);
  });

  ProcessSignal.SIGTERM.watch().listen((_) {
    _stopping = true;
    st.tearDown();
    exit(0);
  });

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

  StreamSubscription subscription;
  subscription = customer.phoneEvents.listen((Phonio.Event event)  {

    // Spawn a new call as soon as the old call is disconnected.
    if(event is Phonio.CallDisconnected) {

      if(_stopping) {
        subscription.cancel();
        return;
      }

      new Future.delayed (new Duration (milliseconds : 100))
        .then((_) => customer.dial(_randomChoice(_receptionNumbers)));
    }
  });

  int numCalls = 4;
  return Future.doWhile(() {
    numCalls = numCalls - 1;
    return customer.dial(_randomChoice(_receptionNumbers)).then((_) {
      return numCalls != 0 && !_stopping;
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
