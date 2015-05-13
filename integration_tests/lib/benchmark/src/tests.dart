part of or_test_fw;

abstract class Benchmark {
  
  static final Logger log = new Logger('$libraryName.Benchmark');
  
  
  static Future _receptionistRequestsCall (Receptionist r) {
    
    bool callAvailable(Model.Call call) => 
      call.assignedTo == Model.User.nullID && !call.locked; 
    
    return r.callFlowControl.callList().then((Iterable<Model.Call> calls) {
      if (calls.isEmpty) {
        return false;
      }
      
      Model.Call nextCall = calls.firstWhere(callAvailable, orElse: () => null);
      
      log.info('$r found $nextCall available');
      log.info('${calls.map((var call) => call.toJson())}');
      
      if (nextCall == null) {
        return new Future.delayed(new Duration (milliseconds : 100), () => _receptionistRequestsCall(r));
      } else {
        return r.pickup(nextCall)
          .then((_) => 
            new Future.delayed(new Duration (milliseconds : 100), () => r.hangUp(nextCall)))
          .catchError((error, stackTrace) {
            if (error is Storage.Conflict) {
              log.info('$nextCall is already assigned, trying the next one.');
              return new Future.delayed(new Duration (milliseconds : 100), () => r.hangUp(nextCall));
            }
            else if (error is Storage.NotFound) {
              log.info('$nextCall is hung up, trying the next one.');
              return new Future.delayed(new Duration (milliseconds : 100), () => r.hangUp(nextCall));
            }
        });
      }
    });
  }
  
  static Future callRush (Iterable<Receptionist> receptionists, Iterable<Customer> customers) {
    Receptionist callWaiter = receptionists.first;
    
    // Each customer spawns a call
    return Future.forEach(customers, (Customer customer) {
      return customer.dial('12340003');
    })
    .then((_) {
      log.info('Waiting for call list to fill');
      return Future.doWhile((() => new Future.delayed(new Duration (milliseconds : 100), 
          () => callWaiter.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
        return calls.length != customers.length;}
      ))));
    })
    .then((_) {
      return Future.forEach(receptionists.take(customers.length), (Receptionist r) {
        log.info('$r finds next call');

        return _receptionistRequestsCall(r);
      });
    })
    .then((_) => log.info('Test done'));
  }
}